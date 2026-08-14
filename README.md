# TaskBoard App

An offline first task board for iPhone that allows users to organize tasks across a simple
workflow. Tasks can move through **To Do, In Progress, Done**, and everything works with no network, and changes sync to a Firebase
Realtime Database when one is reachable.

---

## New Features Added - version 2.0

* Archive and Restore - Users can now archive a task, which then no longer appears on main board. Archived tasks will also remain persisted and will be part of sync flow. All archived tasks can be visible in Archived view where long pressing and clicking Restore to task status restores task to main board.

* Subtasks - A tasks can now have subtasks, where users can add sub tasks and mark it complete or incomplete by clicking radio button and saving tasks. Subtasks can be displayed on main board screen by expand or collapse  icon available when any task have subtasks added. Subtasks can also be removed by swiping left on edit task screen or by long pressing subtask on main board screen.

* Activity History - A read only activity history is displayed when user click on any tasks. User activity is also persisted and synced to remote servers. Users can see Task created, edited, moved between board sections, archived, restored, subtask added, completed, removed along with their timestamp.

* Bug fixes: Now supports dark mode also.

* Note: Users can update to this latest version, every thing will work fine with tasks present in previous version 1.0 and upgrading to this latest. Prefer deleting and reinstalling app to show full activity history.

* Known Limitations:
  * Activity history is capped with maximum of 50 events, where newest first are displayed.

* Future improvements:
  * Activity history does not shows who has edited this task, as we need device or user id for this. I will update this in later version.
  * Deleting a task deletes the history along with it. 

---

## Screenshots

| First launch | Task board | SubTask board | Editing |
|:---:|:---:|:---:|:---:|
| <img src="Screenshots/empty.png" width="200"> | <img src="Screenshots/board.png" width="200"> | <img src="Screenshots/board1.png" width="200"> | <img src="Screenshots/editTask.png" width="200"> |
| Nothing to show yet | Three sections, one scroll | Tasks with sub tasks | Edit task |


| Activity history | Archive |
|:---:|:---:|
| <img src="Screenshots/activity.png" width="200"> | <img src="Screenshots/archive.png" width="200"> |
| Activity history | Archived tasks |

---

## Running it

```bash
open TaskBoard.xcodeproj
```

Build and run on any iPhone simulator, iOS 17 or later, or on iPhone device by adding your registered bundle id and automatic manage signing. It works immediately no configuration, no accounts, no packages to resolve.

---

## What it does - version 1.0

**The board** — There are three sections in one vertical scroll. Create, edit, delete,
drag to reorder, drag between sections. Sections collapse. Long press a task for
Edit, Move to, or Delete without dragging.

**Offline** — Every action works with no network. Changes are written locally,
marked pending, and sent when connectivity returns. Nothing is lost, nothing is
blocked, and the board never waits on a request.

---

## Technical decisions

* SwiftUI for creating Views, SwiftData for database, Swift Concurrency for asynchronous programming, Firebase Realtime Database for remote syncing.
* MVVM with Clean architecture for clear separation of responsibility.
* REST APIs using URLSession for remote sync.
* Network framework for monitor internet connectivity with polling of 30 seconds along with pull to refresh to sync to remote.
* Handled the failure states by showing error label where applicable.
* Database url: https://taskboard-d43b9-default-rtdb.asia-southeast1.firebasedatabase.app

---

## Known limitations

* The remote data is sync with 30 seconds poll to not throttle server, so instant update across device will be seen with 30 second lag.
* If two devices editing same task different fields, later wins as I have used last updated as source of truth.

---

## Feature to Add with more Time

* Background syncing and instant remote syncing.
* Search or filter tasks.
* Undo support after delete task.
* Allow multiple deletes and Saving deleted tasks and showing them in history.
* Unit tests.

---

## Assumptions

* Every device pointing at the same node sees the same
  tasks. No accounts, no per-user boards, no permissions.
* iOS 17 and above are supported due to use of SwiftData
* No authentication is added.

---

## Time spent

* Around 9-10 hours.

---

## AI tools used

* Used Claude and ChatGPT for syntax or pseudo code some framework like SwiftData, Network, and some part of SwiftUI complex rendering.



