local Transacao = {}
Transacao.__index = Transacao

function Transacao.new(cliente, cartao, beneficiado)
    local self = setmetatable({}, Transacao)
    self.cliente = cliente
    self.cartao = cartao
    self.beneficiado = beneficiado
    self.data = os.date("%Y-%m-%d %H:%M:%S")
    return self
end

local Cliente = {}
Cliente.__index = Cliente

function Cliente.new(nome, endereco, contato, cartoes)
    local self = setmetatable({}, Cliente)
    self.nome = nome
    self.endereco = endereco
    self.contato = contato
    self.cartoes = cartoes or {}
    return self
end

local Cartao = {}
Cartao.__index = Cartao

function Cartao.new(numero, dataVencimento)
    local self = setmetatable({}, Cartao)
    self.numero = numero
    self.dataVencimento = dataVencimento
    return self
end

local function criarTransacao(req)
    local cliente = Cliente.new(req.cliente.nome, req.cliente.endereco, req.cliente.contato)
    local cartao = Cartao.new(req.cartao.numero, req.cartao.dataVencimento)
    local transacao = Transacao.new(cliente, cartao, req.beneficiado)
    return transacao
end

local function handleRequest(req)
    if req.method == "POST" then
        if req.path == "/transacoes" then
            local transacao = criarTransacao(req.body)
            -- Aqui você pode salvar a transação no banco de dados
            print("Transação criada com sucesso:", transacao)
            return {status = 201, body = "Transação criada com sucesso"}
        else
            return {status = 404, body = "Endpoint não encontrado"}
        end
    else
        return {status = 405, body = "Método não permitido"}
    end
end

local http = require("socket.http")
local server = require("socket").tcp()
server:bind("*", 8080)
server:listen(5)

print("Servidor HTTP rodando em http://localhost:8080/")

while true do
    local client = server:accept()
    local request = client:receive()
    local headers = {}
    while true do
        local line = client:receive()
        if line == "" then
            break
        end
        local key, value = line:match("([^:]+):%s*(.*)")
        headers[key] = value
    end
    local body = client:receive(headers["content-length"])
    local response = handleRequest({
        method = headers["method"],
        path = headers["path"],
        body = body
    })
    client:send("HTTP/1.1 " .. response.status .. " OK\r\n")
    client:send("Content-Length: " .. #response.body .. "\r\n\r\n")
    client:send(response.body)
    client:close()
end
