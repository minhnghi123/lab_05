const router = require("express").Router();
const ToDocontrollers = require("../controllers/user.controller");

router.post("/login", ToDocontrollers.login);

router.post("/register", ToDocontrollers.register);

module.exports = router;
