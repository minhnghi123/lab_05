const ToDoService = require("../services/todo.service");

exports.createToDo = async (req, res, next) => {
  try {
    const { userId, title, desc } = req.body ?? {};
    if (!userId || !title || !desc) {
      return res
        .status(400)
        .json({ status: false, message: "userId, title, desc are required" });
    }
    let todoData = await ToDoService.createTodo(userId, title, desc);
    res.json({ status: true, success: todoData });
  } catch (error) {
    console.log(error, "err---->");
    next(error);
  }
};

exports.getToDoList = async (req, res, next) => {
  try {
    const userId = req.body?.userId ?? req.query?.userId ?? req.params?.userId;
    if (!userId) {
      return res.status(400).json({ status: false, message: "userId is required" });
    }
    let todoData = await ToDoService.getUserToDoList(userId);
    res.json({ status: true, success: todoData });
  } catch (error) {
    console.log(error, "err---->");
    next(error);
  }
};

exports.deleteToDo = async (req, res, next) => {
  try {
    const { id } = req.body ?? {};
    if (!id) {
      return res.status(400).json({ status: false, message: "id is required" });
    }
    let deletedData = await ToDoService.deleteToDo(id);
    res.json({ status: true, success: deletedData });
  } catch (error) {
    console.log(error, "err---->");
    next(error);
  }
};

exports.updateToDo = async (req, res, next) => {
  try {
    const { id, title, desc } = req.body ?? {};
    if (!id || !title || !desc) {
      return res
        .status(400)
        .json({ status: false, message: "id, title, desc are required" });
    }
    const updatedData = await ToDoService.updateToDo(id, title, desc);
    res.json({ status: true, success: updatedData });
  } catch (error) {
    console.log(error, "err---->");
    next(error);
  }
};
