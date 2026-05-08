const express = require("express");
const bodyParser = require("body-parser");
const UserRoute = require("./routes/user.route.js");
const ToDoRoute = require("./routes/todo.route.js");
const app = express();

app.use(bodyParser.json());

app.use("/", UserRoute);
app.use("/", ToDoRoute);

module.exports = app;
