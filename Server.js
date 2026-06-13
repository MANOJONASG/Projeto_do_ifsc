const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
const session = require('express-session');
const path = require('path');
require('dotenv').config();

const app = express();

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false, maxAge: 1000 * 60 * 60 * 8 }
}));

const pool = mysql.createPool({
  host:     process.env.DB_HOST,
  port:     process.env.DB_PORT,
  user:     process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10
});

function auth(req, res, next) {
  if (!req.session.profileId) return res.status(401).json({ error: 'Não autenticado.' });
  next();
}

app.post('/api/register', async (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password) return res.status(400).json({ error: 'Preencha todos os campos.' });
  const hash = await bcrypt.hash(password, 12);
  try {
    const [result] = await pool.execute(
      'INSERT INTO profiles (name, email, password_hash) VALUES (?, ?, ?)',
      [name, email, hash]
    );
    req.session.profileId = result.insertId;
    req.session.email = email;
    res.json({ message: 'Cadastro realizado.' });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ error: 'E-mail já cadastrado.' });
    res.status(500).json({ error: 'Erro interno.' });
  }
});

app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Preencha e-mail e senha.' });
  const [[profile]] = await pool.execute('SELECT * FROM profiles WHERE email = ?', [email]);
  if (!profile) return res.status(401).json({ error: 'E-mail ou senha incorretos.' });
  const match = await bcrypt.compare(password, profile.password_hash);
  if (!match) return res.status(401).json({ error: 'E-mail ou senha incorretos.' });
  await pool.execute('INSERT INTO sessions (profile_id) VALUES (?)', [profile.id]);
  req.session.profileId = profile.id;
  req.session.email = profile.email;
  res.json({ message: 'Login realizado.', name: profile.name, email: profile.email });
});

app.post('/api/logout', auth, async (req, res) => {
  await pool.execute(
    'UPDATE sessions SET logged_out_at = NOW(), active = 0 WHERE profile_id = ? AND active = 1',
    [req.session.profileId]
  );
  req.session.destroy();
  res.json({ message: 'Sessão encerrada.' });
});

app.get('/api/tasks', auth, async (req, res) => {
  const [tasks] = await pool.execute(
    'SELECT * FROM tasks WHERE profile_id = ? ORDER BY deadline ASC',
    [req.session.profileId]
  );
  res.json(tasks);
});

app.post('/api/tasks', auth, async (req, res) => {
  const { title, description, deadline } = req.body;
  if (!title || !description || !deadline) return res.status(400).json({ error: 'Preencha todos os campos.' });
  const [result] = await pool.execute(
    'INSERT INTO tasks (profile_id, title, description, deadline) VALUES (?, ?, ?, ?)',
    [req.session.profileId, title, description, deadline]
  );
  const [[task]] = await pool.execute('SELECT * FROM tasks WHERE id = ?', [result.insertId]);
  res.status(201).json(task);
});

app.put('/api/tasks/:id', auth, async (req, res) => {
  const { title, description, deadline } = req.body;
  const [result] = await pool.execute(
    'UPDATE tasks SET title = ?, description = ?, deadline = ? WHERE id = ? AND profile_id = ?',
    [title, description, deadline, req.params.id, req.session.profileId]
  );
  if (result.affectedRows === 0) return res.status(404).json({ error: 'Tarefa não encontrada.' });
  const [[task]] = await pool.execute('SELECT * FROM tasks WHERE id = ?', [req.params.id]);
  res.json(task);
});

app.delete('/api/tasks/:id', auth, async (req, res) => {
  const [result] = await pool.execute(
    'DELETE FROM tasks WHERE id = ? AND profile_id = ?',
    [req.params.id, req.session.profileId]
  );
  if (result.affectedRows === 0) return res.status(404).json({ error: 'Tarefa não encontrada.' });
  res.json({ message: 'Tarefa excluída.' });
});

app.get('/api/tasks/expired', auth, async (req, res) => {
  const [tasks] = await pool.execute(
    'SELECT * FROM tasks WHERE profile_id = ? AND expired = 1 ORDER BY deadline DESC',
    [req.session.profileId]
  );
  res.json(tasks);
});

app.post('/api/tasks/check-expired', auth, async (req, res) => {
  await pool.execute('CALL sp_check_expired_tasks()');
  res.json({ message: 'Tarefas expiradas atualizadas.' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor rodando em http://localhost:${PORT}`));
