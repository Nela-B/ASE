const mongoose = require('mongoose');

const errandSchema = new mongoose.Schema({
  id: { type: Number, required: true },
  title: { type: String, required: true },
  description: String,
  isCompleted: { type: Boolean, default: false }
});

module.exports = mongoose.model('errand', errandSchema);