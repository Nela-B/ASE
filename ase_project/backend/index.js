const express = require('express');
const app = express();
const PORT = 3000;

app.use(express.json()); // Allows Express to parse JSON bodies

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});


const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost:27017/todoapp', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => console.log('Database connected'))
  .catch(err => console.log(err));


const Task = require('./models/task');

app.post('/api/tasks/create', async (req, res) => {
  const { title, description, priority } = req.body;

  if (!title) {
    return res.status(400).json({ message: 'Title is required' });
  }

  try {
    const task = new Task({ title, description, priority });
    await task.save();
    res.status(201).json(task);
  } catch (error) {
    res.status(500).json({ message: 'Error creating task', error });
  }
});



app.get('/api/tasks/list', async (req, res) => {
    try {
      const tasks = await Task.find();
      res.status(200).json(tasks);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching tasks', error });
    }
});