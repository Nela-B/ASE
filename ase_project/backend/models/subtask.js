const mongoose = require('mongoose');

const subTaskSchema = new mongoose.Schema({
    title: String,
    completed: { type: Boolean, default: false },
  });

module.exports = mongoose.model('Task', subTaskSchema);
