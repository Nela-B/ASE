const mongoose = require('mongoose');
const SubTask = require('./subtask.js');

const taskSchema = new mongoose.Schema({
  // id: { type: Number, required: true },
  title: { type: String, required: true },
  description: String,
  deadlineType: { type: String, enum: ['specific', 'today', 'this week', 'none'], default: 'none' },
  dueDate: { type: Date },
  isCompleted: { type: Boolean, default: false },
  subtasks: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Subtask' }],  
  urgency: { type: String, enum: ['urgent', 'not urgent'], default: 'not urgent' },
  importance: { type: String, enum: ['important', 'not important'], default: 'not important' },
  links: [String],
  filePaths: [String],
  notify: { type: Boolean, default: false },
  frequency: { type: String, enum: ['daily', 'weekly', 'monthly', 'yearly', 'custom'], default: 'none' },
  interval: { type: Number },
  byDay: { type: [String] },
  byMonthDay: { type: Number },
  recurrenceEndType: { type: String, enum: ['never', 'date', 'occurrences'], default: 'never' },
  recurrenceEndDate: { type: Date },
  maxOccurrences: { type: Number },
  points: { type: Number, default: 0 }
});

module.exports = mongoose.model('Task', taskSchema);
