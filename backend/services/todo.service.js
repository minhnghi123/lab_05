const { deleteToDo } = require("../controllers/todo.controller");
const ToDoModel = require("../models/todo.model");

class TodoService {
  static async createTodo(userId, title, description) {
    const createdTodo = await ToDoModel.create({ userId, title, description });
    return createdTodo;
  }
  static async getUserToDoList(userId) {
    const todoList = await ToDoModel.find({ userId });
    return todoList;
  }

  static async deleteToDo(id) {
    const deleted = await ToDoModel.findByIdAndDelete({ _id: id });
    return deleted;
  }

  static async updateToDo(id, title, description) {
    const updated = await ToDoModel.findByIdAndUpdate(
      { _id: id },
      { title, description },
      { new: true },
    );
    return updated;
  }
}
module.exports = TodoService;
