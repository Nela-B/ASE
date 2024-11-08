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

//  Main Task Routes


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

// Update a Main Task 
app.put('/api/tasks/:taskId', async (req, res) => {
  const { taskId } = req.params;
  const { title, description, priority } = req.body;

  try {
    const task = await Task.findById(taskId);

    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    task.title = title || task.title;
    task.description = description || task.description;
    task.priority = priority || task.priority;

    await task.save();
    res.status(200).json(task);
  } catch (error) {
    res.status(500).json({ message: 'Error updating task', error });
  }
});

// Delete a Main Task 
app.delete('/api/tasks/:taskId', async (req, res) => {
  const { taskId } = req.params;

  try {
    const task = await Task.findById(taskId);

    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    await task.remove();
    res.status(200).json({ message: 'Task deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting task', error });
  }
});

// Sub-task Routes


// Add Sub-task
app.post('/api/tasks/:taskId/subtasks', async (req, res) => {
  const { taskId } = req.params;
  const { title, description, completed } = req.body;

  if (!title) {
    return res.status(400).json({ message: 'Sub-task title is required' });
  }

  try {
    const task = await Task.findById(taskId);

    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    const newSubTask = { title, description, completed };
    task.subTasks.push(newSubTask);

    await task.save();
    res.status(201).json(newSubTask);
  } catch (error) {
    res.status(500).json({ message: 'Error adding sub-task', error });
  }
});

// Update Sub-task
app.put('/api/tasks/:taskId/subtasks/:subTaskId', async (req, res) => {
  const { taskId, subTaskId } = req.params;
  const { title, description, completed } = req.body;

  try {
    const task = await Task.findById(taskId);

    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    const subTask = task.subTasks.id(subTaskId);

    if (!subTask) {
      return res.status(404).json({ message: 'Sub-task not found' });
    }

    subTask.title = title || subTask.title;
    subTask.description = description || subTask.description;
    subTask.completed = completed !== undefined ? completed : subTask.completed;

    await task.save();
    res.status(200).json(subTask);
  } catch (error) {
    res.status(500).json({ message: 'Error updating sub-task', error });
  }
});

// Delete Sub-task
app.delete('/api/tasks/:taskId/subtasks/:subTaskId', async (req, res) => {
  const { taskId, subTaskId } = req.params;

  try {
    const task = await Task.findById(taskId);

    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    const subTask = task.subTasks.id(subTaskId);

    if (!subTask) {
      return res.status(404).json({ message: 'Sub-task not found' });
    }

    subTask.remove();
    await task.save();

    res.status(200).json({ message: 'Sub-task deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting sub-task', error });
  }
});
