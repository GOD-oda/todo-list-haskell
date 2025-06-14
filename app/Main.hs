{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Main where

import Web.Scotty
import Data.Aeson (FromJSON, ToJSON)
import Data.Text
import Data.Map
import Data.IORef
import Control.Monad.IO.Class (liftIO)
import System.IO.Unsafe
import qualified Data.Map as Map
import GHC.Generics (Generic)
import Network.HTTP.Types.Status (status201) -- TODO: このエラーは謎
import Data.UUID.V4(nextRandom)
import Data.UUID(toString)

type TodoStore = Map Text TodoItem
todoStore :: IORef TodoStore
todoStore = unsafePerformIO $ newIORef Map.empty
{-# NOINLINE todoStore #-}

data TodoItem = TodoItem
    {
        todoId :: Text,
        title :: Text
    } deriving (Show, Generic)
instance ToJSON TodoItem

getAllTodos :: IO [TodoItem]
getAllTodos = do
    store <- readIORef todoStore
    return $ Map.elems store

generateUuid :: IO Text
generateUuid = do
    pack . toString <$> nextRandom

data CreateTodoRequest = CreateTodoRequest
    {
        todoTitle :: Text
    } deriving (Generic)
instance ToJSON CreateTodoRequest
instance FromJSON CreateTodoRequest

createTodo :: CreateTodoRequest -> IO TodoItem
createTodo req = do
    uuid <- generateUuid
    let todoItem = TodoItem {
        todoId = uuid,
        title = todoTitle req
    }
    modifyIORef' todoStore $ Map.insert uuid todoItem
    return todoItem


main :: IO ()
main = do
    scotty 3000 $ do
        get "/todos" $ do
            todos <- liftIO getAllTodos
            json todos

        post "/todos" $ do
            req <- jsonData :: ActionM CreateTodoRequest
            todo <- liftIO $ createTodo req
            status status201
            json todo

--
--{-# LANGUAGE DeriveGeneric #-}
--
--module Main where
--
--import Web.Scotty
--import Data.Aeson (FromJSON, ToJSON)
--import GHC.Generics (Generic)
--import Data.Text.Lazy (Text)
--import qualified Data.Text.Lazy as TL
--import qualified Data.Map as Map
--import Data.Map (Map)
--import Control.Monad.IO.Class (liftIO)
--import Data.IORef
--import Data.UUID (UUID)
--import qualified Data.UUID as UUID
--import qualified Data.UUID.V4 as UUID
--import Data.Time.Clock (UTCTime, getCurrentTime)
--import System.IO.Unsafe (unsafePerformIO)
--
---- | ToDo item data model
--data TodoItem = TodoItem
--  { todoId :: Text
--  , title :: Text
--  , description :: Text
--  , completed :: Bool
--  , createdAt :: UTCTime
--  , updatedAt :: UTCTime
--  } deriving (Show, Generic)
--
--instance ToJSON TodoItem
--instance FromJSON TodoItem
--
---- | Request body for creating a new ToDo item
--data CreateTodoRequest = CreateTodoRequest
--  { createTitle :: Text
--  , createDescription :: Text
--  } deriving (Show, Generic)
--
--instance FromJSON CreateTodoRequest
--instance ToJSON CreateTodoRequest
--
---- | Request body for updating a ToDo item
--data UpdateTodoRequest = UpdateTodoRequest
--  { updateTitle :: Maybe Text
--  , updateDescription :: Maybe Text
--  , updateCompleted :: Maybe Bool
--  } deriving (Show, Generic)
--
--instance FromJSON UpdateTodoRequest
--instance ToJSON UpdateTodoRequest
--
---- | In-memory storage for ToDo items
--type TodoStore = Map Text TodoItem
--
---- | Global state for the application
--todoStore :: IORef TodoStore
--todoStore = unsafePerformIO $ newIORef Map.empty
--{-# NOINLINE todoStore #-}
--
---- | Generate a new UUID as Text
--generateUUID :: IO Text
--generateUUID = do
--  uuid <- UUID.nextRandom
--  return $ TL.pack $ UUID.toString uuid
--
---- | Create a new ToDo item
--createTodo :: CreateTodoRequest -> IO TodoItem
--createTodo req = do
--  uuid <- generateUUID
--  now <- getCurrentTime
--  let todo = TodoItem
--        { todoId = uuid
--        , title = createTitle req
--        , description = createDescription req
--        , completed = False
--        , createdAt = now
--        , updatedAt = now
--        }
--  modifyIORef' todoStore $ Map.insert uuid todo
--  return todo
--
---- | Get all ToDo items
--getAllTodos :: IO [TodoItem]
--getAllTodos = do
--  store <- readIORef todoStore
--  return $ Map.elems store
--
---- | Get a ToDo item by ID
--getTodoById :: Text -> IO (Maybe TodoItem)
--getTodoById todoId = do
--  store <- readIORef todoStore
--  return $ Map.lookup todoId store
--
---- | Update a ToDo item
--updateTodo :: Text -> UpdateTodoRequest -> IO (Maybe TodoItem)
--updateTodo todoId req = do
--  store <- readIORef todoStore
--  now <- getCurrentTime
--  case Map.lookup todoId store of
--    Nothing -> return Nothing
--    Just todo -> do
--      let updatedTodo = todo
--            { title = maybe (title todo) id (updateTitle req)
--            , description = maybe (description todo) id (updateDescription req)
--            , completed = maybe (completed todo) id (updateCompleted req)
--            , updatedAt = now
--            }
--      modifyIORef' todoStore $ Map.insert todoId updatedTodo
--      return $ Just updatedTodo
--
---- | Delete a ToDo item
--deleteTodo :: Text -> IO Bool
--deleteTodo todoId = do
--  store <- readIORef todoStore
--  case Map.lookup todoId store of
--    Nothing -> return False
--    Just _ -> do
--      modifyIORef' todoStore $ Map.delete todoId
--      return True
--
--main :: IO ()
--main = do
--  putStrLn "Starting ToDo List API server on http://localhost:3000"
--  scotty 3000 $ do
--    -- CORS middleware
--    middleware $ \app req respond -> do
--      app req $ \response -> do
--        respond $ response
--          { Web.Scotty.responseHeaders =
--              [("Access-Control-Allow-Origin", "*"),
--               ("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS"),
--               ("Access-Control-Allow-Headers", "Content-Type")]
--          }
--
--    -- Handle OPTIONS requests for CORS preflight
--    options (regex ".*") $ do
--      setHeader "Access-Control-Allow-Origin" "*"
--      setHeader "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS"
--      setHeader "Access-Control-Allow-Headers" "Content-Type"
--      status 200
--
--    -- List all ToDo items
--    get "/todos" $ do
--      todos <- liftIO getAllTodos
--      json todos
--
--    -- Get a specific ToDo item
--    get "/todos/:id" $ do
--      todoId <- param "id"
--      maybeTodo <- liftIO $ getTodoById todoId
--      case maybeTodo of
--        Nothing -> do
--          status 404
--          json $ object ["error" .= ("Todo item not found" :: Text)]
--        Just todo -> json todo
--
--    -- Create a new ToDo item
--    post "/todos" $ do
--      req <- jsonData :: ActionM CreateTodoRequest
--      todo <- liftIO $ createTodo req
--      status 201
--      json todo
--
--    -- Update a ToDo item
--    put "/todos/:id" $ do
--      todoId <- param "id"
--      req <- jsonData :: ActionM UpdateTodoRequest
--      maybeTodo <- liftIO $ updateTodo todoId req
--      case maybeTodo of
--        Nothing -> do
--          status 404
--          json $ object ["error" .= ("Todo item not found" :: Text)]
--        Just todo -> json todo
--
--    -- Delete a ToDo item
--    delete "/todos/:id" $ do
--      todoId <- param "id"
--      deleted <- liftIO $ deleteTodo todoId
--      if deleted
--        then status 204 >> text ""
--        else do
--          status 404
--          json $ object ["error" .= ("Todo item not found" :: Text)]
