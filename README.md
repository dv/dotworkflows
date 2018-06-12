# Github to Things 3

The first workflow loads all PR review requests from Github from a specific organization specified in an ENV variable, as todos into a specific project in Things 3.

When the review request is fulfilled, it also automatically marks that todo as done.

# Setup

- Create a .env file and fill in the required parameters (see sample file)
- Run it manually to check that it works: `ruby review_requests_to_things`

# Launchctl

To automatically make it run, edit the `workflow.plist` file with the correct paths for your installation, then link it into the `LaunchAgents` folder, with a custom name, for example:

```
ln workflow.plist ~/Library/LaunchAgents/com.crowdway.workflow.plist
```

And then load it:
```
launchctl load ~/Library/LaunchAgents/com.crowdway.workflow.plist
```

This will cause the ruby script to run every two minutes, or according to the interval specified in `workflow.plist`


# Things in Applescript

Things have their own Documentation on Applescript automation: https://support.culturedcode.com/customer/en/portal/articles/2803572-using-applescript-with-things

## Misc

Check `lists` for todos in Evening and Today etc

```
[25] pry(main)> things.osa_object.lists.get
=> [app("/Applications/Things3.app").lists.ID("TMInboxListSource"),
 app("/Applications/Things3.app").lists.ID("TMTodayListSource"),
 app("/Applications/Things3.app").lists.ID("TMNextListSource"),
 app("/Applications/Things3.app").lists.ID("TMCalendarListSource"),
 app("/Applications/Things3.app").lists.ID("TMSomedayListSource"),
 app("/Applications/Things3.app").lists.ID("THMLonelyLaterProjectsListSource"),
 app("/Applications/Things3.app").lists.ID("TMLogbookListSource"),
 app("/Applications/Things3.app").lists.ID("TMTrashListSource"),
 app("/Applications/Things3.app").areas.ID("THMAreaParentSource/9510E1D3-3F67-4AFC-BDD0-B2AB928AE11A"),
 app("/Applications/Things3.app").areas.ID("THMAreaParentSource/689A12C3-6406-43FC-ADE7-7C9AF0453B06"),
 app("/Applications/Things3.app").areas.ID("THMAreaParentSource/2BF8B679-1AC4-4423-849E-02DF65E7CCD8"),
 app("/Applications/Things3.app").areas.ID("THMAreaParentSource/4823B1EA-3116-49C3-BD88-D4E1F91DC116")]
[26] pry(main)>

things.osa_object.lists.ID("TMNextListSource").to_dos.get

```

## Todo

Call `_properties.get` to see list of values

```
todo.osa_object.properties_.get
=> {:status=>:open,
 :tag_names=>"",
 :cancellation_date=>:missing_value,
 :due_date=>:missing_value,
 :class_=>:selected_to_do,
 :modification_date=>2018-06-10 14:11:47 +0300,
 :contact=>:missing_value,
 :project=>app("/Applications/Things3.app").projects.ID("AFE0D059-E6EE-49A6-9879-E87963518FD6"),
 :area=>:missing_value,
 :notes=>"",
 :activation_date=>2018-06-10 00:00:00 +0300,
 :id_=>"18F1713E-CF63-4F3E-93CA-72B7A8175DA1",
 :completion_date=>:missing_value,
 :name=>"todo this evening",
 :creation_date=>2018-06-10 14:11:41 +0300}
```

Call `methods` to see a list of possible methods and fields.

### status

- `open`: not completed, not cancelled
- `completed`: completed (completion_date and cancellation_date will be filled in)
- `canceled`: cancelled (completion_date and cancellation_date will be filled in)

By changing `status = completed` it sets `activation_date` to nil and sets `completion_date`. You cannot set `status = open` but rather you have to set `completion_date` back to `nil`.

Note: when a todo is logged it is no longer in that project or area, but is in the Logbook. It will not show up in the Project as completed todos. Only non-logged, completed todos show up when filtering for completion.

### show

Shows the todo in the GUI (navigates to the correct project too)

### edit

Opens to todo edit input box

### activation_date

```ruby
todo.osa_object.activation_date.get
```

- For a todo on Today: `2018-06-10 00:00:00 +0300` (today's date)
- For a todo this Evening: `2018-06-10 00:00:00 +0300` (today's date)
- For a todo for Tomorrow: `2018-06-11 00:00:00 +0300` (tomorrow's date)
