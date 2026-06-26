# Projeto IFSC - Gerenciador de Tarefas Acadêmicas

Sistema web para organização de tarefas, prazos e atividades acadêmicas com autenticação segura via MySQL.

## 🚀 Como Começar

### 1. **Instalar Dependências**
```bash
npm install
```

### 2. **Configurar Banco de Dados**
- Certifique-se de que MySQL está rodando
- Importe o arquivo `projeto_ifsc.sql`:
```bash
mysql -u root -p < projeto_ifsc.sql
```

### 3. **Configurar Variáveis de Ambiente**
Crie um arquivo `.env` na raiz do projeto (ou copie `.env.example`):
```
PORT=3000
SESSION_SECRET=seu_secret_muito_seguro_aqui_2024
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASS=sua_senha_mysql
DB_NAME=projeto_ifsc
```

### 4. **Iniciar o Servidor**
```bash
npm start
# ou
node Server.js
```

O servidor estará disponível em: **http://localhost:3000**

---

## 📋 Funcionalidades

✅ **Autenticação Segura**
- Registro de usuários com criptografia bcrypt
- Login com sessão persistente
- Logout seguro

✅ **Gerenciamento de Tarefas**
- Criar, editar e deletar tarefas
- Definir prazos e descrições
- Visualizar tarefas ordenadas por deadline
- Alerta automático para tarefas expiradas
- Lembretes para tarefas vencendo em 24h

✅ **Persistência em Banco de Dados**
- Dados armazenados em MySQL
- UUIDs para identificação única
- Relacionamentos entre usuários e tarefas

---

## 🏗️ Estrutura do Projeto

```
projeto-ifsc/
├── Server.js                  # Servidor Express + API REST
├── projeto_ifsc.sql          # Schema do banco de dados
├── .env                       # Variáveis de ambiente
├── .env.example              # Exemplo de variáveis
├── Package.json              # Dependências do projeto
└── public/
    └── index.html            # Frontend (HTML + CSS + JS)
```

---

## 📡 API REST

### Autenticação
- `POST /api/register` - Registrar novo usuário
- `POST /api/login` - Fazer login
- `POST /api/logout` - Fazer logout

### Tarefas
- `GET /api/tasks` - Listar tarefas do usuário
- `POST /api/tasks` - Criar nova tarefa
- `PUT /api/tasks/:id` - Editar tarefa
- `DELETE /api/tasks/:id` - Deletar tarefa
- `GET /api/tasks/expired` - Listar tarefas expiradas
- `POST /api/tasks/check-expired` - Verificar tarefas expiradas

---

## 🔒 Segurança

- Senhas criptografadas com bcrypt (salt rounds: 12)
- Sessões protegidas com express-session
- Queries parametrizadas (proteção contra SQL Injection)
- Validação de entrada em todos os endpoints

---

## 🛠️ Tecnologias

**Backend:**
- Node.js + Express.js
- MySQL 8.0+
- bcrypt para criptografia
- express-session para gerenciamento de sessões

**Frontend:**
- HTML5 + CSS3
- JavaScript Vanilla (Fetch API)
- Design responsivo

---

## 📝 Dados de Teste

O banco de dados inclui 3 usuários pré-cadastrados:

| Email | Senha | Nome |
|-------|-------|------|
| jonas@ifsc.edu.br | password123 | Jonas Silva |
| maria@ifsc.edu.br | password456 | Maria Oliveira |
| pedro@aluno.ifsc.edu.br | password789 | Pedro Souza |

---

## 🐛 Troubleshooting

**Erro: "Cannot find module"**
```bash
npm install
```

**Erro: "Conexão com banco recusada"**
- Verifique se MySQL está rodando
- Confirme credenciais no `.env`
- Verifique se o banco `projeto_ifsc` foi importado

**Erro: "Session secret not configured"**
- Adicione `SESSION_SECRET` ao `.env`

---

## 📧 Suporte

Para problemas ou dúvidas, verifique:
1. Arquivo `.env` está configurado corretamente
2. MySQL está rodando e banco foi importado
3. Porta 3000 está disponível
4. Node.js versão 14+ está instalado

---

## 📄 Licença

Projeto desenvolvido para o IFSC.
