const express = require('express');
const app = express();
const PORT = 3000;

const fs = require('fs');

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
  const {
    title,
    description,
    priority,
    deadlineType,
    dueDate,
    dueTime,
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
    points,
    completionDate,
    subTasks, // Include subtasks in the payload
  } = req.body;

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
      dueTime,
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
      points,
      completionDate,
    });

    // Process and attach subtasks if provided
    if (subTasks && Array.isArray(subTasks)) {
      const savedSubTasks = await Promise.all(
        subTasks.map(async (subTask) => {
          const newSubTask = new SubTask(subTask); // Create subtask document
          await newSubTask.save(); // Save subtask in the database
          return newSubTask._id; // Return the subtask ID
        })
      );
      mainTask.subtasks = savedSubTasks; // Add subtask IDs to the main task
    }

    await mainTask.save();
    res.status(201).json(mainTask);
  } catch (error) {
    console.error('Error creating task:', error);
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
  

// Update the isCompleted attribute of a main task
app.patch('/api/tasks/:taskId/completed', async (req, res) => {
  const { taskId } = req.params;
  const { isCompleted } = req.body; // Get isCompleted value from request body

  if (typeof isCompleted !== 'boolean') {
    return res.status(400).json({ message: 'isCompleted must be a boolean value' });
  }

  try {
    const taskObjectId = new mongoose.Types.ObjectId(taskId); // Convert taskId to ObjectId if needed

    // Update fields based on isCompleted value
    const updateFields = {
      isCompleted,
      completionDate: isCompleted ? new Date() : null, // Set to current date or reset to null
    };

    const updatedTask = await Task.findByIdAndUpdate(
      taskObjectId,
      updateFields, // Update isCompleted and completionDate fields
      { new: true } // Return the updated document
    );

    if (!updatedTask) {
      return res.status(404).json({ message: 'Task not found' });
    }

    res.status(200).json(updatedTask); // Send the updated task in response
  } catch (error) {
    console.error('Error updating task completion:', error);
    res.status(500).json({ message: 'Error updating task completion', error: error.message });
  }
});


// Delete a Main Task 
app.delete('/api/tasks/delete/:id', async (req, res) => {
  try {
    const taskId = req.params.id; // Get task ID from the request URL
    const result = await Task.findByIdAndDelete(taskId);

    if (!result) {
      return res.status(404).json({ message: 'Task not found' });
    }
    res.status(200).json({ message: 'Task deleted successfully', task: result });
  } catch (error) {
    console.error('Error deleting task:', error);
    res.status(500).json({ message: 'Error deleting task', error });
  }
});



//-----------------------------------------------------------------------------------------------------------------//
// Sub-task Routes
//-----------------------------------------------------------------------------------------------------------------//

const SubTask = require('./models/subtask');

// Add Sub-task to a Main Task
app.post('/api/tasks/:taskId/subtasks', async (req, res) => {
  const { taskId } = req.params;
  const { title, description, deadlineType, dueDate, urgency, importance, links, filePaths, notify, frequency, interval, byDay, byMonthDay, recurrenceEndType, recurrenceEndDate, maxOccurrences, points } = req.body;

  if (!title) {
    return res.status(400).json({ message: 'Sub-task title is required' });
  }

  try {
    if (!mongoose.Types.ObjectId.isValid(taskId)) {
      return res.status(400).json({ message: 'Invalid task ID' });
    }

    const mainTask = await Task.findById(taskId);
    if (!mainTask) {
      return res.status(404).json({ message: 'Main task not found' });
    }

    // Create a new subtask
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

    // Save the subtask first so that _id is automatically generated
    await subTask.save();

    // Add the newly created subtask to the mainTask's subtasks array
    mainTask.subtasks.push(subTask);

    // Save the main task
    await mainTask.save();

    res.status(201).json(subTask);
  } catch (error) {
    console.error('Error creating sub-task:', error);
    return res.status(500).json({
      message: 'Error adding sub-task',
      error: error.message || error.toString(),
    });
  }
});


// Fetch Subtasks of a Specific Task
app.get('/api/tasks/:taskId/subtask/list', async (req, res) => {
  const { taskId } = req.params;

  try {
    // Check if taskId is valid
    if (!mongoose.Types.ObjectId.isValid(taskId)) {
      return res.status(400).json({ message: 'Invalid task ID' });
    }

    // Fetch main task by taskId and populate its subtasks
    const mainTask = await Task.findById(taskId).populate('subtasks');

    // Check if mainTask exists
    if (!mainTask) {
      return res.status(404).json({ message: 'Main task not found' });
    }

    // Check if subtasks is an array
    const subtasks = Array.isArray(mainTask.subtasks) ? mainTask.subtasks : [];

    // If no subtasks, return an empty array
    if (subtasks.length === 0) {
      return res.status(200).json({ subtasks: [] });
    }

    // Return subtasks
    res.status(200).json({ subtasks: subtasks });
  } catch (error) {
    console.error('Error fetching subtasks:', error);
    res.status(500).json({ message: 'Error fetching subtasks' });
  }
});



// Update a Sub-task
app.put('/api/tasks/subtasks/:subTaskId', async (req, res) => {
  const { subTaskId } = req.params; // Only receive subTaskId, no need for taskId
  const { title, description, completed } = req.body;

  try {
    // Find the subtask by subTaskId
    const subTask = await SubTask.findById(subTaskId);

    if (!subTask) {
      return res.status(404).json({ message: 'Sub-task not found' });
    }

    // Update the subtask fields
    subTask.title = title || subTask.title;
    subTask.description = description || subTask.description;
    subTask.completed = completed !== undefined ? completed : subTask.completed;

    await subTask.save(); // Save the updated subtask
    res.status(200).json(subTask); // Return the updated subtask
  } catch (error) {
    res.status(500).json({ message: 'Error updating sub-task', error });
  }
});


app.delete('/api/tasks/delete/subtask/:subTaskId', async (req, res) => {
  try {
    const subTaskId = req.params.subTaskId; // Get subTaskId from the request URL
    console.log('Deleting Subtask with ID:', subTaskId); // Debugging log
    const result = await SubTask.findByIdAndDelete(subTaskId);

    if (!result) {
      return res.status(404).json({ message: 'Subtask not found' });
    }
    res.status(200).json({ message: 'Subtask deleted successfully', task: result });
  } catch (error) {
    console.error('Error deleting subtask:', error);
    res.status(500).json({ message: 'Error deleting subtask', error });
  }
});


// Update the isCompleted attribute of a subtask
app.patch('/api/subtasks/:subtaskId/completed', async (req, res) => {
  const { subtaskId } = req.params;
  const { isCompleted } = req.body; // Get isCompleted value from request body

  if (typeof isCompleted !== 'boolean') {
    return res.status(400).json({ message: 'isCompleted must be a boolean value' });
  }

  try {
    const subtaskObjectId = new mongoose.Types.ObjectId(subtaskId); // Convert taskId to ObjectId if needed

    // Update fields based on isCompleted value
    const updateFields = {
      isCompleted,
      completionDate: isCompleted ? new Date() : null, // Set to current date or reset to null
    };

    const updatedSubTask = await SubTask.findByIdAndUpdate(
      subtaskObjectId,
      updateFields, // Update isCompleted and completionDate fields
      { new: true } // Return the updated document
    );

    if (!updatedSubTask) {
      return res.status(404).json({ message: 'SubTask not found' });
    }

    res.status(200).json(updatedSubTask); // Send the updated task in response
  } catch (error) {
    console.error('Error updating subtask completion:', error);
    res.status(500).json({ message: 'Error updating subtask completion', error: error.message });
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


//-----------------------------------------------------------------------------------------------------------------//
// Charts Routes
//-----------------------------------------------------------------------------------------------------------------//


app.get('/api/charts/daily-points', async (req, res) => {
  try {
    const tasks = await Task.find({ isCompleted: true });
    //console.log('Fetched tasks:', tasks); // Log tasks fetched from DB

    const dailyPoints = {};
    tasks.forEach(task => {
      if (task.completionDate) {
        const date = task.completionDate.toISOString().split('T')[0];
        dailyPoints[date] = (dailyPoints[date] || 0) + task.points;
      }
    });

    //console.log('Processed daily points:', dailyPoints); // Log calculated data
    res.status(200).json(dailyPoints);
  } catch (error) {
    console.error('Error in /api/charts/daily-points:', error); // Log error details
    res.status(500).json({ message: 'Error fetching daily points', error });
  }
});


app.get('/api/charts/accumulated-points', async (req, res) => {
  try {
    const tasks = await Task.find({ isCompleted: true });
    //console.log('Fetched tasks:', tasks); // Log fetched tasks from DB

    const dailyPoints = {};
    tasks.forEach(task => {
      if (task.completionDate) { // Ensure dueDate exists
        const date = task.completionDate.toISOString().split('T')[0];
        dailyPoints[date] = (dailyPoints[date] || 0) + task.points;
      }
    });

    //console.log('Daily points data:', dailyPoints); // Log daily points before accumulation

    const sortedDates = Object.keys(dailyPoints).sort();
    //console.log('Sorted dates:', sortedDates); // Log sorted dates

    let accumulated = 0;
    const accumulatedPoints = sortedDates.map(date => {
      accumulated += dailyPoints[date];
      return { date, points: accumulated };
    });

    //console.log('Accumulated points:', accumulatedPoints); // Log accumulated points data
    res.status(200).json(accumulatedPoints);
  } catch (error) {
    console.error('Error in /api/charts/accumulated-points:', error); // Log error details
    res.status(500).json({ message: 'Error fetching accumulated points', error });
  }
});



const getWeekNumber = (date) => {
  const firstDay = new Date(date.getFullYear(), 0, 1);
  const dayNumber = Math.floor((date - firstDay) / (24 * 60 * 60 * 1000));
  return Math.ceil((dayNumber + firstDay.getDay() + 1) / 7);
};

app.get('/api/charts/weekly-points', async (req, res) => {
  try {
    const tasks = await Task.find({ isCompleted: true });
    //console.log('Fetched tasks:', tasks); // Log fetched tasks

    const weeklyPoints = {};
    tasks.forEach(task => {
      if (task.completionDate) {
        const completionDate = new Date(task.completionDate);
        if (!isNaN(completionDate)) {
          const week = getWeekNumber(completionDate);
          weeklyPoints[week] = (weeklyPoints[week] || 0) + task.points;
        }
      }
    });

    // Convert object keys to integers (ensure backend sends integers as keys)
    const formattedWeeklyPoints = Object.fromEntries(
      Object.entries(weeklyPoints).map(([key, value]) => [parseInt(key, 10), value])
    );

    //console.log('Formatted weekly points:', formattedWeeklyPoints);
    res.status(200).json(formattedWeeklyPoints);
  } catch (error) {
    console.error('Error in /api/charts/weekly-points:', error);
    res.status(500).json({ message: 'Error fetching weekly points', error });
  }
});



app.get('/api/charts/monthly-points', async (req, res) => {
  try {
    const tasks = await Task.find({ isCompleted: true });
    const monthlyPoints = {};

    tasks.forEach(task => {
      if (task.completionDate) {
        const completionDate = new Date(task.completionDate);
        if (!isNaN(completionDate)) {
          const month = completionDate.getMonth() + 1; // 1-indexed month
          monthlyPoints[month] = (monthlyPoints[month] || 0) + task.points;
        }
      }
    });

    //console.log('Raw monthly points:', monthlyPoints); // Debug log

    // Ensure integer keys are sent in the JSON response
    const formattedMonthlyPoints = Object.fromEntries(
      Object.entries(monthlyPoints).map(([key, value]) => [parseInt(key, 10), value])
    );

    //console.log('Formatted monthly points:', formattedMonthlyPoints); // Debug log
    res.status(200).json(formattedMonthlyPoints);
  } catch (error) {
    console.error('Error in /api/charts/monthly-points:', error);
    res.status(500).json({ message: 'Error fetching monthly points', error });
  }
});





app.get('/api/charts/tasks-completion', async (req, res) => {
  const tasks = await Task.find({ isCompleted: true });

  const completedBeforeDueDate = tasks.filter(task => {
    const completionDate = new Date(task.completionDate);
    const dueDate = new Date(task.dueDate);
    return completionDate < dueDate; // Completed before the due date
  }).length;

  const completedAfterDueDate = tasks.filter(task => {
    const completionDate = new Date(task.completionDate);
    const dueDate = new Date(task.dueDate);
    return completionDate >= dueDate; // Completed on or after the due date
  }).length;

  res.json({ completedBeforeDueDate, completedAfterDueDate });
});

//-----------------------------------------------------------------------------------------------------------------//
// BACKUP Routes
//-----------------------------------------------------------------------------------------------------------------//

app.post('/api/tasks/restore', async (req, res) => {
  const { backupPath } = req.body;

  if (!backupPath) {
    return res.status(400).json({ message: 'Backup path is required' });
  }

  try {
    // Read data from the backup file path
    const backupData = fs.readFileSync(backupPath, 'utf8'); // Read the JSON file as a string
    const tasks = JSON.parse(backupData); // Convert the string to a JSON object

    // Initialize an array to hold updated tasks
    const updatedTasks = [];

    // Loop through the tasks in the backup data and either update or insert them
    for (const task of tasks) {
      // Try to find the task by its unique identifier (e.g., id)
      const existingTask = await Task.findOne({ _id: task._id });

      if (existingTask) {
        // If the task already exists, update it
        Object.assign(existingTask, task);  // Merge the existing task with the backup data
        await existingTask.save();  // Save the updated task
        updatedTasks.push(existingTask);
      } else {
        // If the task does not exist, create a new one
        const newTask = new Task(task);
        await newTask.save();  // Insert the new task into the database
        updatedTasks.push(newTask);
      }
    }

    // Return the updated tasks list
    return res.status(200).json(updatedTasks); // Return the updated or newly added tasks list
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Error restoring tasks', error: error.message });
  }
});
