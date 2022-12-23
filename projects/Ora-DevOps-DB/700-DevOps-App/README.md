# DevOps App

## Button Themes

* Save
  * Button Template: Text with Icon
  * `Hot: True`
  * Icon: `fa-save`
* Create
  * Button Template: Text with Icon
  * Template Options: Type: Success
  * Icon: `fa-plus-circle-o`
* Delete
  * Button Template: Text with Icon
  * Template Options: Type: Danger
  * Icon: `fa-trash-o`
* Recycle
  * Button Template: Text with Icon
  * Template Options: Type: Danger
  * Icon: `fa-recycle` 
* Archive
  * Button Template: Text with Icon
  * Template Options: Type: ??
  * Icon: `fa-archive`
* Search
  * Button Template: Text with Icon
  * Template Options: Type: Success
  * Icon: `fa-fa-search`

## Interactive Report Button Themes

* JavaScript Initialization Code

```javascript
function(config){
    let $ = apex.jQuery,
    toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(),
    toolbarGroup3 = toolbarData.toolbarFind("actions3");
    toolbarGroup4 = toolbarData.toolbarFind("actions4");
    addrowAction = toolbarData.toolbarFind("selection-add-row"),
    saveAction = toolbarData.toolbarFind("save"),
    editAction = toolbarData.toolbarFind("edit"),
    resetAction = toolbarData.toolbarFind("reset-report");

    addrowAction.id = "add";
    addrowAction.iconBeforeLabel = true;
    addrowAction.icon = "fa fa-plus-circle-o"; // icon added

    saveAction.id = "save";
    saveAction.iconBeforeLabel = true;
    saveAction.icon = "fa fa-save";
    saveAction.hot = true;

    editAction.id = "edit";
    editAction.iconBeforeLabel = true;
    editAction.icon ="fa fa-edit";

    resetAction.id = "reset";
    resetAction.enabled = true;

    toolbarGroup3.controls.push({
        id: "create",
        type: "BUTTON",
        action: "apex.navigation.redirect('f?p=100:6::::::\u0026cs=');",
        label: "Create",
        iconBeforeLabel: true,
        icon: "fa fa-plus-circle-o",
        hot: false
    });

    //class: "a-Button a-Toolbar-item a-Button--withIcon a-Button--danger",
    toolbarGroup4.controls.push({
        id: "delete",
        type: "BUTTON",
        action: "selection-delete",
        icon: "fa fa-trash",
        iconBeforeLabel: true,
        hot: false
    });

    config.toolbarData = toolbarData;
    return config;
}

//
/*
apex.item('pFlowId').getValue() // APP_ID
apex.item('pFlowStepId').getValue() // APP_PAGE_ID
apex.item('pInstance').getValue() // APP_SESSION

// config.defaultGridViewOptions = {
//     content: function(callback, model, recordMeta, colMeta, columnDef){
//     }
// }
*/

```

* Execute when Page Loads

```javascript
$("#source").appendTo("#destination");

document.getElementById("gridEdit1_ig_toolbar_delete").classList.add("t-Button--danger");
document.getElementById("gridEdit1_ig_toolbar_create").classList.add("t-Button--success");
document.getElementById("gridEdit1_ig_toolbar_add").classList.add("t-Button--success");
document.getElementById("gridEdit1_ig_toolbar_reset").classList.add("t-Button--warning");

```




<button class="t-Button t-Button--icon t-Button--success t-Button--iconLeft lto3900831433871604_0" onclick="apex.navigation.redirect('f?p=100:6:10289264384294::::P6_ID:\u0026cs=3QNW18W5tgB9lsnz3zJ0tGJrT_gXhTEENpRk-T5W0EuWZcBzz5FNukg7NGq9TbTcWOkTbHjvSC7_3NdvMED_Z7w');" type="button" id="B3900831433871604"><span class="t-Icon t-Icon--left fa fa-plus-circle-o" aria-hidden="true"></span><span class="t-Button-label">Create</span><span class="t-Icon t-Icon--right fa fa-plus-circle-o" aria-hidden="true"></span></button>