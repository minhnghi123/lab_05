const db = require("../config/db.js");
const UserModel = require("./user.model.js");
const mongoose = require("mongoose");
const { Schema } = mongoose;

const toDoSchema = new Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
  },
  {
    timestamps: true,
  },
);

const ToDoModel = mongoose.model("todos", toDoSchema);

module.exports = ToDoModel;
