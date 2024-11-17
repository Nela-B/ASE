const express = require('express');
const app = express();
const PORT = 3000;

app.use(express.json()); // Allows Express to parse JSON bodies

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});


const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost:27017/todoapp', {
  useNewUrlParser: true, // Can be commented out if using the latest MongoDB versio
  useUnifiedTopology: true, // Can be commented out if using the latest MongoDB versio
}).then(() => console.log('Database connected'))
  .catch(err => console.log(err));


const Task = require('./models/task');

//-----------------------------------------------------------------------------------------------------------------//
//  Main Task Routes
//-----------------------------------------------------------------------------------------------------------------//

// Create a new Main Task
app.post('/api/tasks/create', async (req, res) => {
  const { title, description, priority, deadlineType, dueDate, urgency, importance, links, filePaths, notify, frequency, interval, byDay, byMonthDay, recurrenceEndType, recurrenceEndDate, maxOccurrences, points } = req.body;

  if (!title) {
    return res.status(400).json({ message: 'Title is required' });
  }

  try {
    const mainTask = new Task({
      title,
      description,
      priority,
      deadlineType,
      dueDate,
      urgency,
      importance,
      links,
      filePaths,
      notify,
      frequency,
      interval,
      byDay,
      byMonthDay,
      recurrenceEndType,
      recurrenceEndDate,
      maxOccurrences,
      points
    });

    await mainTask.save();
    res.status(201).json(mainTask);
  } catch (error) {
    res.status(500).json({ message: 'Error creating task', error });
  }
});

// Get all tasks
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
  const { title, description, priority, deadlineType, dueDate, urgency, importance, links, filePaths, notify, frequency, interval, byDay, byMonthDay, recurrenceEndType, recurrenceEndDate, maxOccurrences, points } = req.body;

  const taskObjectId = new mongoose.Types.ObjectId(taskId);
  if (!title && !description && !priority) {
    return res.status(400).json({ message: 'At least one field (title, description, priority) must be provided to update' });
  }
try {
    const updatedTask = await Task.findByIdAndUpdate(
      taskObjectId, 
      {
        title,
        description,
        priority,
        deadlineType,
        dueDate,
        urgency,
        importance,
        links,
        filePaths,
        notify,
        frequency,
        interval,
        byDay,
        byMonthDay,
        recurrenceEndType,
        recurrenceEndDate,
        maxOccurrences,
        points
      },
      { new: true } 
    );
    if (!updatedTask) {
      return res.status(404).json({ message: 'Task not found' });
    }

    res.status(200).json(updatedTask);  
  } catch (error) {
    console.error('Error updating task:', error);
    res.status(500).json({ message: 'Error updating task', error: error.message });
  }
});
  


// Delete a Main Task 
app.delete('/api/tasks/:taskId', async (req, res) => {
  const { taskId } = req.params;

  try {
    const mainTask = await MainTask.findById(taskId);

    if (!mainTask) {
      return res.status(404).json({ message: 'Main task not found' });
    }

    await mainTask.remove();
    res.status(200).json({ message: 'Main task deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting task', error });
  }
});



//-----------------------------------------------------------------------------------------------------------------//
// Sub-task Routes
//-----------------------------------------------------------------------------------------------------------------//

// Add Sub-task to a Main Task
app.post('/api/tasks/:taskId/subtasks', async (req, res) => {
  const { taskId } = req.params;
  const { title, description, deadlineType, dueDate, urgency, importance, links, filePaths, notify, frequency, interval, byDay, byMonthDay, recurrenceEndType, recurrenceEndDate, maxOccurrences, points } = req.body;

  if (!title) {
    return res.status(400).json({ message: 'Sub-task title is required' });
  }

  try {
    const mainTask = await MainTask.findById(taskId);

    if (!mainTask) {
      return res.status(404).json({ message: 'Main task not found' });
    }

    const subTask = new SubTask({
      title,
      description,
      deadlineType,
      dueDate,
      urgency,
      importance,
      links,
      filePaths,
      notify,
      frequency,
      interval,
      byDay,
      byMonthDay,
      recurrenceEndType,
      recurrenceEndDate,
      maxOccurrences,
      points
    });

    mainTask.subtasks.push(subTask);
    await mainTask.save();

    res.status(201).json(subTask);
  } catch (error) {
    res.status(500).json({ message: 'Error adding sub-task', error });
  }
});

// Update a Sub-task
app.put('/api/tasks/:taskId/subtasks/:subTaskId', async (req, res) => {
  const { taskId, subTaskId } = req.params;
  const { title, description, completed } = req.body;

  try {
    const mainTask = await MainTask.findById(taskId);

    if (!mainTask) {
      return res.status(404).json({ message: 'Main task not found' });
    }

    const subTask = mainTask.subtasks.id(subTaskId);

    if (!subTask) {
      return res.status(404).json({ message: 'Sub-task not found' });
    }

    subTask.title = title || subTask.title;
    subTask.description = description || subTask.description;
    subTask.completed = completed !== undefined ? completed : subTask.completed;

    await mainTask.save();
    res.status(200).json(subTask);
  } catch (error) {
    res.status(500).json({ message: 'Error updating sub-task', error });
  }
});

// Delete a Sub-task
app.delete('/api/tasks/:taskId/subtasks/:subTaskId', async (req, res) => {
  const { taskId, subTaskId } = req.params;

  try {
    const mainTask = await MainTask.findById(taskId);

    if (!mainTask) {
      return res.status(404).json({ message: 'Main task not found' });
    }

    const subTask = mainTask.subtasks.id(subTaskId);

    if (!subTask) {
      return res.status(404).json({ message: 'Sub-task not found' });
    }

    subTask.remove();
    await mainTask.save();

    res.status(200).json({ message: 'Sub-task deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting sub-task', error });
  }
});


//-----------------------------------------------------------------------------------------------------------------//
// Errand Routes
//-----------------------------------------------------------------------------------------------------------------//

// Add Errand to Subtask
app.post('/api/tasks/:taskId/subtasks/:subTaskId/errands', async (req, res) => {
  const { taskId, subTaskId } = req.params;
  const { title, description, isCompleted } = req.body;

  if (!title) {
    return res.status(400).json({ message: 'Errand title is required' });
  }

  try {
    const mainTask = await MainTask.findById(taskId);

    if (!mainTask) {
      return res.status(404).json({ message: 'Main task not found' });
    }

    const subTask = mainTask.subtasks.id(subTaskId);

    if (!subTask) {
      return res.status(404).json({ message: 'Sub-task not found' });
    }

    const errand = new Errand({
      title,
      description,
      isCompleted: isCompleted || false
    });

    subTask.errands.push(errand);
    await mainTask.save();

    res.status(201).json(errand);
  } catch (error) {
    res.status(500).json({ message: 'Error adding errand', error });
  }
});

// Update an Errand
app.put('/api/tasks/:taskId/subtasks/:subTaskId/errands/:errandId', async (req, res) => {
  const { taskId, subTaskId, errandId } = req.params;
  const { title, description, isCompleted } = req.body;

  try {
    const mainTask = await MainTask.findById(taskId);

    if (!mainTask) {
      return res.status(404).json({ message: 'Main task not found' });
    }

    const subTask = mainTask.subtasks.id(subTaskId);

    if (!subTask) {
      return res.status(404).json({ message: 'Sub-task not found' });
    }

    const errand = subTask.errands.id(errandId);

    if (!errand) {
      return res.status(404).json({ message: 'Errand not found' });
    }

    errand.title = title || errand.title;
    errand.description = description || errand.description;
    errand.isCompleted = isCompleted !== undefined ? isCompleted : errand.isCompleted;

    await mainTask.save();
    res.status(200).json(errand);
  } catch (error) {
    res.status(500).json({ message: 'Error updating errand', error });
  }
});

// Delete an Errand
app.delete('/api/tasks/:taskId/subtasks/:subTaskId/errands/:errandId', async (req, res) => {
  const { taskId, subTaskId, errandId } = req.params;

  try {
    const mainTask = await MainTask.findById(taskId);

    if (!mainTask) {
      return res.status(404).json({ message: 'Main task not found' });
    }

    const subTask = mainTask.subtasks.id(subTaskId);

    if (!subTask) {
      return res.status(404).json({ message: 'Sub-task not found' });
    }

    const errand = subTask.errands.id(errandId);

    if (!errand) {
      return res.status(404).json({ message: 'Errand not found' });
    }

    errand.remove();
    await mainTask.save();

    res.status(200).json({ message: 'Errand deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting errand', error });
  }
});
