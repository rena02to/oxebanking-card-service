-- Servidor HTTP simples
local server = require("socket").tcp()
server:bind("*", 8080)
server:listen(5)

print("Servidor HTTP rodando em http://localhost:8080/")

while true do
    local client = server:accept()
    local response = "HTTP/1.1 200 OK\r\nContent-Length: 13\r\n\r\nHello, World!"
    client:send(response)
    client:close()
end
