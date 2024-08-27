# API Odontológica - Frontend

## Descrição

Este é o repositório do frontend da aplicação API Odontológica, desenvolvida em Flutter. A aplicação permite o gerenciamento de agendamentos, pacientes, dentistas e salas, voltada para clínicas odontológicas. A interface é intuitiva e moderna, facilitando a navegação e a operação do sistema.

## Funcionalidades

- **Gerenciamento de Agendamentos:** Criação, edição e exclusão de agendamentos para pacientes.
- **Listagem de Pacientes e Dentistas:** Visualize, adicione e edite informações de pacientes e dentistas.
- **Interface de Agenda:** Veja os agendamentos organizados em um calendário semanal.
- **Filtro de Pesquisa:** Permite pesquisar agendamentos por nome de paciente ou dentista.

## Requisitos

- Flutter 3.x ou superior
- Dart 2.18 ou superior
- Conexão com o backend da API Odontológica

## Instalação e Configuração

1. **Clone o repositório:**

    ```bash
    git clone https://github.com/usuario/api-odontologica-frontend.git
    ```

2. **Navegue até o diretório do projeto:**

    ```bash
    cd api-odontologica-frontend
    ```

3. **Instale as dependências:**

    ```bash
    flutter pub get
    ```

4. **Configuração do Backend:**

   No arquivo `lib/services/api_service.dart`, atualize a variável `baseUrl` para apontar para o endpoint correto da API backend:

    ```dart
    final String baseUrl = 'http://localhost:8080/api';
    ```

5. **Execute a aplicação:**

    ```bash
    flutter run -d chrome --web-port=53385
    ```

## Estrutura do Projeto

- `lib/screens/` - Contém as telas principais da aplicação, como agendamentos, pacientes, dentistas e salas.
- `lib/services/` - Contém os serviços responsáveis por realizar as requisições HTTP ao backend.
- `lib/main.dart` - Arquivo principal que inicializa o aplicativo e define as rotas.

## Rotas Principais

- `/` - HomePage (Página Principal)
- `/agendamentos` - Lista de Agendamentos
- `/agenda` - Visualização da Agenda em formato de calendário
- `/pacientes` - Lista de Pacientes

## Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Faça um fork do repositório.
2. Crie uma branch para a sua feature (`git checkout -b minha-feature`).
3. Commit suas mudanças (`git commit -m 'Adiciona minha feature'`).
4. Faça um push para a branch (`git push origin minha-feature`).
5. Abra um Pull Request.

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para mais detalhes.

