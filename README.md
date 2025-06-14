# ToDo List API Server

A simple RESTful API server for managing ToDo items, implemented in Haskell using Scotty.

## Features

- Create, read, update, and delete ToDo items
- In-memory storage (data is lost when the server restarts)
- JSON API with proper HTTP status codes
- CORS support for cross-origin requests

## API Endpoints

### List all ToDo items

```
GET /todos
```

Response:
```json
[
  {
    "todoId": "123e4567-e89b-12d3-a456-426614174000",
    "title": "Buy groceries",
    "description": "Milk, eggs, bread",
    "completed": false,
    "createdAt": "2023-05-20T10:00:00Z",
    "updatedAt": "2023-05-20T10:00:00Z"
  },
  {
    "todoId": "223e4567-e89b-12d3-a456-426614174001",
    "title": "Finish project",
    "description": "Complete the Haskell ToDo API",
    "completed": true,
    "createdAt": "2023-05-19T14:30:00Z",
    "updatedAt": "2023-05-20T09:15:00Z"
  }
]
```

### **Not Implemented** Get a specific ToDo item
```
GET /todos/:id
```

Response:
```json
{
  "todoId": "123e4567-e89b-12d3-a456-426614174000",
  "title": "Buy groceries",
  "description": "Milk, eggs, bread",
  "completed": false,
  "createdAt": "2023-05-20T10:00:00Z",
  "updatedAt": "2023-05-20T10:00:00Z"
}
```

### Create a new ToDo item

```
POST /todos
```

Request body:
```json
{
  "createTitle": "Call mom",
  "createDescription": "Call mom for her birthday"
}
```

Response:
```json
{
  "todoId": "323e4567-e89b-12d3-a456-426614174002",
  "title": "Call mom",
  "description": "Call mom for her birthday",
  "completed": false,
  "createdAt": "2023-05-20T11:30:00Z",
  "updatedAt": "2023-05-20T11:30:00Z"
}
```

### **Not Implemented** Update a ToDo item

```
PUT /todos/:id
```

Request body:
```json
{
  "updateTitle": "Call mom and dad",
  "updateDescription": "Call mom and dad for their anniversary",
  "updateCompleted": true
}
```

Response:
```json
{
  "todoId": "323e4567-e89b-12d3-a456-426614174002",
  "title": "Call mom and dad",
  "description": "Call mom and dad for their anniversary",
  "completed": true,
  "createdAt": "2023-05-20T11:30:00Z",
  "updatedAt": "2023-05-20T12:15:00Z"
}
```

### **Not Implemented** Delete a ToDo item

```
DELETE /todos/:id
```

Response: 204 No Content

## Running the Server

1. Make sure you have GHC and Cabal installed
2. Clone this repository
3. Build the project:
   ```
   cabal build
   ```
4. Run the server:
   ```
   cabal run
   ```
5. The server will start on http://localhost:3000

## Development
```shell
cabal update
```

### Dependencies

- scotty: Web framework
- aeson: JSON serialization/deserialization
- text: Text manipulation
- uuid: Generating unique IDs
- time: Handling timestamps
- containers: Data structures like Map

### Project Structure

- `app/Main.hs`: Main application code
- `todo-list-haskell.cabal`: Project configuration
