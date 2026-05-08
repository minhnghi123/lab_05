const router = require("express").Router();
const ToDocontrollers = require("../controllers/todo.controller");

router.post("/createToDo", ToDocontrollers.createToDo);

router.get("/getUserTodoList", ToDocontrollers.getToDoList);

router.put("/updateTodo", ToDocontrollers.updateToDo);

router.post("/deleteTodo", ToDocontrollers.deleteToDo);

module.exports = router;
