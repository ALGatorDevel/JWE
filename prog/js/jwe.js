
///////////////////////////////////////////////////////////////////////////////
//
//
//
// COMMON functions
//
//
//
///////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// Function displays element
//-----------------------------------------------------------------------------

function showElement(elementId)
{
	$('#' + elementId).fadeIn(400);
}

//----------------------------------------------------------------------------
// Function hides element
//-----------------------------------------------------------------------------

function hideElement(elementId, mode)
{
	if (mode == null)
	{
		$('#' + elementId).fadeOut(400);
	}
	else
	{
		$('#' + elementId).hide();
	}
}

//----------------------------------------------------------------------------
// Function toggles visibility of element
//-----------------------------------------------------------------------------

function toggleDisplay(elementId)
{
	$('#' + elementId).fadeToggle(400);
}

//----------------------------------------------------------------------------
//Function toggles visibility of element
//-----------------------------------------------------------------------------

function clickButton(id)
{
	$('#' + id).click();
}

//----------------------------------------------------------------------------
// Function deletes row from table
//-----------------------------------------------------------------------------

function deleteTableRow(rowId)
{
	$('#' + rowId).fadeOut(400, function(){
		$('#' + rowId).remove();
    });
}

//----------------------------------------------------------------------------
// Function creates form adds parameters and so simulates post call
//-----------------------------------------------------------------------------

function postwith (to,p)
{
	var myForm = document.createElement("form");
	
	myForm.method="post" ;
	myForm.action = to ;
	  
	for (var k in p)
	{
		var myInput = document.createElement("input") ;
		    
		myInput.setAttribute("name", k) ;
		myInput.setAttribute("value", p[k]);
		
		myForm.appendChild(myInput) ;
	}
	  
	document.body.appendChild(myForm) ;
	
	myForm.submit() ;
	
	document.body.removeChild(myForm) ;
}

//----------------------------------------------------------------------------
// Function opens new location using post method
//-----------------------------------------------------------------------------

function openLocation(projectId, eType, eName, action)
{
	var parameters = new Object();
	
	if (projectId.length > 0)
	{
		parameters['pId'] = projectId;
	}

	if (eType.length > 0)
	{
		parameters['eType'] = eType;
	}
	
	if (eName.length > 0)
	{
		parameters['eName'] = eName;
	}
	
	if (action.length > 0)
	{
		parameters['performAction'] = action;
	}
	
	postwith('jwe.pl', parameters);
}


//----------------------------------------------------------------------------
// Function which registers submit form
//-----------------------------------------------------------------------------

function registerSubmitForm(formId, message, fileSelectionId, func, displayMessage, errorMessageId)
{
	$('#' + formId).submit(function()
	{
         /* submit the uploadForm */
         $.ajax({

        	 url: 'jwe.pl',
        	 data: $(this).serialize(),
        	 type: 'post',
        	 
        	 success: function(response) {
        		 
        		 var errorText = "";
        		 
        		 if (response != "1")
        		 {
        			 errorText = "Ne morem shraniti entitete!" . $errorText;
        		 }
        		 
        		 $("#" + errorMessageId).text(errorText);
        		 
	             if (typeof func == "function")
                 {
                	 func();
                 }
        	 }
         });
         
         return false;
	});
}  			

//----------------------------------------------------------------------------
//Function which registers submit form
//-----------------------------------------------------------------------------

function registerSubmitForm2(formId, message, fileSelectionId, func)
{
	$('#' + formId).submit(function()
			{
	  			
	  			$('<input type="hidden" name="javascript" value="yes" />').appendTo($(this));
	  			
	  			var iframeId = 'iframeUpload';
	  			var iframeName = (iframeId);
	            var iframeTemp = $('<iframe name="'+iframeName+'" src="about:blank" />');
	             
	            iframeTemp.css('display', 'none');
	             
	            $('body').append(iframeTemp);
	             
	             /* submit the uploadForm */
	             $(this).attr({				
	                 action: 'jwe.pl',
	                 method: 'post',
	                 enctype: 'multipart/form-data',
	                 encoding: 'multipart/form-data',
	                 target: iframeName
	             });
	             
	             setTimeout(function()
	             {
	            	 iframeTemp.remove();
	            	 
	            	 $('input[name="javascript"]').remove();
	            	 
	            	 inputLength = 0;
	            	 
	            	 if (fileSelectionId.length == 0)
	            	 {
	            		 inputLength = 10;
	            	 }
	            	 else
	            	 {
	            		 inputLength += $('input[name="' + fileSelectionId + '"]').val().length;
	            	 }
	            	 
	            	 if(0 < inputLength)
	            	 {
	                     $('body').append('<div id="ty" class="thankyouModal">' + message + '</div>');
	            	 }
	            	 
	            	 var modalMarginTop = ($('#ty').height() + 60) / 2;
	                 var modalMarginLeft = ($('#ty').width() + 60) / 2;
	                 
	                 /* apply the margins to the modal window */
	                 $('#ty').css(
	                 {
	                        'margin-top'    : -modalMarginTop,
	                        'margin-left'     : -modalMarginLeft
	                 });
	                 
	                 $('.thankyouModal').fadeIn('slow', function()
	                 {
	                         $(this).fadeOut(1500, function()
	                         {
	                        	$(this).remove();
	                         });
	                 });
	            	 
	                 if (typeof func == "function")
	                 {
	                	 func();
	                 }
	                 
	             }, 1000);
	  		});
}  			

//----------------------------------------------------------------------------
// Function validates field value using pattern and sets background color
//-----------------------------------------------------------------------------

function validate(value, elementId, pattern, errorMessageId)
{
	$.ajax({    // ajax call starts
    	url     : 'jwe.pl', // JQuery loads serverside.php
    	type    : "POST",
        data    : "performAction=ValidateField&amp;$1=" + value + "&amp;$2=" + pattern,
        dataType: 'text', 
        
        success: function(data) // Variable data contains the data we get from serverside
        {
			if (data == "1")
			{
	        	$('#' + elementId).css('background-color', '#ffffff');
			}
			else
			{
	        	$('#' + elementId).css('background-color', '#ffb4bc');
			}

			var errorText = "";
   		 
   		    if (data != "1")
    		{
    			errorText = "Napaka pri validaciji!"
    		}
    		 
    		$("#" + errorMessageId).text(errorText);
        }
    });
}

//----------------------------------------------------------------------------
//Function validates field value using pattern and sets background color
//-----------------------------------------------------------------------------

var saveTimeout = -1;

function setSaveTimeout(submitButtonId)
{
	if (saveTimeout != -1)
	{
		clearTimeout(saveTimeout);
	}
	
	saveTimeout = setTimeout(
			function()
			{
				clickButton(submitButtonId);
				saveTimeout = -1;
			},
			2000);
}

function validateAndSave(value, elementId, pattern, validateEntry, submitButtonId, errorMessageId)
{
	if (validateEntry == 1)
	{
		$.ajax({    // ajax call starts
			url     : 'jwe.pl', // JQuery loads serverside.php
			type    : "POST",
			data    : "performAction=ValidateField&amp;$1=" + value + "&amp;$2=" + pattern,
			dataType: 'text', 
	     
			success: function(data) // Variable data contains the data we get from server side
			{
				if (data == "1")
				{
			    	$('#' + elementId).css('background-color', '#ffffff');
			    	
			    	setSaveTimeout(submitButtonId);
				}
				else
				{
			    	$('#' + elementId).css('background-color', '#ffb4bc');
				}

				var errorText = "";
	    		 
	   		    if (data != "1")
	    		{
	    			errorText = "Napaka pri validaciji!"
	    		}
	    		 
	    		$("#" + errorMessageId).text(errorText);
			}
		});
	}
	else
	{
		setSaveTimeout(submitButtonId);
	}
}


///////////////////////////////////////////////////////////////////////////////
//
//
//
// FILE MANAGER functions
//
//
//
///////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// File manager variables
//-----------------------------------------------------------------------------

var fileManagerRootFolder       = "";
var fileManagerCurrentFolder    = "";
var fileManagerSelectedfile     = "";
var fileManagerCopyFileLocation = "";
var fileManagerCutFileFlag      = "";

var toolbarButtonFolderUp    = "";
var toolbarButtonCopyFile    = "";
var toolbarButtonCutFile     = "";
var toolbarButtonDeleteFile  = "";
var toolbarButtonPasteFile   = "";

//----------------------------------------------------------------------------
// Function which starts file upload in file manager
//
// Function registers change event and presses button for file upload
//-----------------------------------------------------------------------------

function fileManagerInitToolbar(folderUp, copyFile, cutFile, deleteFile, pasteFile)
{
	toolbarButtonFolderUp    = "#" + folderUp;
	toolbarButtonCopyFile    = "#" + copyFile;
	toolbarButtonCutFile     = "#" + cutFile;
	toolbarButtonDeleteFile  = "#" + deleteFile;
	toolbarButtonPasteFile   = "#" + pasteFile;
}

// ----------------------------------------------------------------------------
// Function which starts file upload in file manager
//
// Function registers change event and presses button for file upload
//-----------------------------------------------------------------------------

function fileManagerUploadFile(fileControlId, fileUploadButtonId)
{
	$("#" + fileControlId).change(function()
			{
				$("#" + fileUploadButtonId).click();
			}).click();
}

//-----------------------------------------------------------------------------
// Function which starts file upload in file manager
//-----------------------------------------------------------------------------

function fileManagerBrowseFolder(fileManagerId, folder, initialize, absPath) 
{
	if (initialize == 1)
	{
		fileManagerCurrentFolder = "";
	}
	
	$.post("jwe.pl",
			{
		  		'performAction':"GetFileInfo",
		  		'$1':encodeURIComponent(folder),
		  		'$2':encodeURIComponent(fileManagerCurrentFolder),
		  		'$3':absPath,
		  		'$4':fileManagerRootFolder
			},

			function(data,status) {

				var grid = jQuery("#" + fileManagerId);

				grid.clearGridData(true);

				var j = 0;
				
		        var path = data.split("@");
		        
		        fileManagerCurrentFolder = path[0];

		        grid.setCaption(fileManagerCurrentFolder);
		        
		        $('#uploadFolder').val(fileManagerCurrentFolder + "/");
		        
		        var res = path[1].split("|");
		        var rootFolder = true;
		        
		        res.forEach(function(entry)
		        {
		            var res2 = entry.split("/");
		            
		            var filetype = res2[0];
		            var filename = res2[1];
		            var filesize = res2[2];
		            
		            var type = 0;
		            
		            var icon = "images/Document-icon.png";
		            
		            if (filetype == "folder")
		            {
		            	icon = "images/Folder-icon.png";
		            	filesize = 0;
		            	
		            	type = 1;
		            }
		            
		            if (filename == "..")
		            {
		            	rootFolder = false;
		            }
		            
		            var fileinfo = {"Type" : type, "Icon": "<img src=\"" + icon + "\"></img>", "Filename": filename, "Size":filesize};
		            
		            grid.jqGrid('addRowData', j, fileinfo);
		            
		            j = j + 1;
		        });
		        
		        grid.trigger("reloadGrid");

		        $(toolbarButtonFolderUp)  .prop('disabled', rootFolder);
		    	$(toolbarButtonCopyFile)  .prop('disabled', true);
		    	$(toolbarButtonCutFile)   .prop('disabled', true);
		        $(toolbarButtonDeleteFile).prop('disabled', true);
			});
}

//-----------------------------------------------------------------------------
// Function which creates folder
//-----------------------------------------------------------------------------

function fileManagerCreateFolder(fileManagerId)
{
	var folderName = prompt("Please enter name of new folder");
	
	if (folderName == null)
	{
		return;
	}

	$.post("jwe.pl",
			{
		  		'performAction':"CreateFolder",
		  		'$1':encodeURIComponent(fileManagerCurrentFolder),
		  		'$2':encodeURIComponent(folderName)
		  	},

			function(data,status) {
		  		fileManagerBrowseFolder(fileManagerId, fileManagerCurrentFolder, 1, 1);
		  	});
}

//-----------------------------------------------------------------------------
// Function which deletes folder/folder
//-----------------------------------------------------------------------------

function fileManagerDeleteFile(fileManagerId)
{
	var answer = confirm("Do you really want to delete selected file/folder?");
	
	if (answer == false)
	{
		return;
	}
	
	var grid = jQuery("#" + fileManagerId);
	var fileData = grid.jqGrid('getRowData', fileManagerSelectedfile);
	
	var filename = fileManagerCurrentFolder + "/" + fileData["Filename"];

	$.post("jwe.pl",
			{
		  		'performAction':"DeleteFile",
		  		'$1':encodeURIComponent(filename)
		  	},

			function(data,status) {
		  		fileManagerBrowseFolder(fileManagerId, fileManagerCurrentFolder, 1, 1);
		  	});
}

//-----------------------------------------------------------------------------
// Function which file manager uses for sorting
//-----------------------------------------------------------------------------

var myCustomSort = function(cell,rowObject) {
	return (1 - parseInt(rowObject["Type"])) + cell.toUpperCase();
}

//-----------------------------------------------------------------------------
// Function which creates file manager
//-----------------------------------------------------------------------------

function fileManagerCreateGrid(fileManagerId, rootFolder, currentFolder, multiSelect)
{
	jQuery("#" + fileManagerId).jqGrid(
  			{
	            datatype: "local",
	            colNames: ['Type', 'Icon', 'Filename', 'Size'],
			    colModel:
			    [ 
			 		{name:'Type', index:'Type', width:8, hidden:true}, 
			 		{name:'Icon', index:'Icon', width:8, sortable:false, resizable:false}, 
			      	{name:'Filename', index:'Filename', width:100, sorttype:myCustomSort}, 
			      	{name:'Size', index:'Size', width:40, align: 'right', sorttype:"int"} 
			    ],
			    userData: {"folder": ""},
			    sortname: 'Filename',
			    sortorder: 'asc',
			    viewrecords: true,
			    caption: 'File Manager',
			    sortable: true,
			    autowidth:true,
			    height:400,
			    rowNum: 10000,
			    multiselect: multiSelect,
			    onSelectRow: function(id)
			    {
			    	fileManagerSelectedfile = id; 
			        
			    	$(toolbarButtonCopyFile)  .prop('disabled', false);
			    	$(toolbarButtonCutFile)   .prop('disabled', false);
			        $(toolbarButtonDeleteFile).prop('disabled', false);
			    },
			    ondblClickRow: function(id)
			    {
			    	var grid = jQuery("#" + fileManagerId);
			    	var fileData = grid.jqGrid('getRowData', id);
			    	
			    	if (fileData["Type"] == 1)
			    	{
			    		fileManagerBrowseFolder(fileManagerId, fileData["Filename"], 0, 0);
			    	}
			    }
			});

	fileManagerRootFolder = rootFolder;
	fileManagerCurrentFolder = currentFolder;
		
	fileManagerBrowseFolder("list", fileManagerCurrentFolder, 1, 1);
	
}

//-----------------------------------------------------------------------------
// Function which registers form for uploading file
//-----------------------------------------------------------------------------

function fileManagerSubmitForm(fileManagerId, formId, message, fileSelectionId)
{
	registerSubmitForm2(formId, message, fileSelectionId,
			function()
			{
				fileManagerBrowseFolder(fileManagerId, fileManagerCurrentFolder, 1, 1);
			});
}

//-----------------------------------------------------------------------------
// Function which copies file name to clipboard
//-----------------------------------------------------------------------------

function fileManagerCopyFileToClipboard(fileManagerId)
{
	var grid = jQuery("#" + fileManagerId);
	var fileData = grid.jqGrid('getRowData', fileManagerSelectedfile);
	
	var filename = fileManagerCurrentFolder + "/" + fileData["Filename"];
	
	fileManagerCopyFileLocation = filename;
	
	$(toolbarButtonPasteFile).prop('disabled', false);
	
	fileManagerCutFileFlag = 0;
}

//-----------------------------------------------------------------------------
// Function which cuts file name to clipboard
//-----------------------------------------------------------------------------

function fileManagerCutFileToClipboard(fileManagerId)
{
	copyFileToClipboard(fileManagerId);

	fileManagerCutFileFlag = 1;
}

//-----------------------------------------------------------------------------
// Function which pastes file name from clipboard
//-----------------------------------------------------------------------------

function fileManagerPasteFile(fileManagerId)
{
	var filename = fileManagerCopyFileLocation;

	$.ajax({    // ajax call starts
    	url     : 'performAction.pl', // JQuery loads serverside.php
    	type    : "POST",
        data    : "performAction=pasteFile&amp;filename=" + encodeURIComponent(filename) + "&amp;destination=" + encodeURIComponent(fileManagerCurrentFolder) + "&amp;cutFlag=" + fileManagerCutFileFlag,
        dataType: 'text', 
        
        success: function(data) // Variable data contains the data we get from serverside
        {
        	fileManagerBrowseFolder(fileManagerId, fileManagerCurrentFolder, 1, 1);
        }
    });
	
	if (fileManagerCutFileFlag == 1)
	{
		fileManagerCopyFileLocation = "";
		fileManagerCutFileFlag = 0;
	}
	
	if (fileManagerCopyFileLocation == "")
	{
        $(toolbarButtonPasteFile).prop('disabled', true);
	}
	else
	{
        $(toolbarButtonPasteFile).prop('disabled', false);
	}
}

//-----------------------------------------------------------------------------
// Function which opens file manager
//-----------------------------------------------------------------------------

var inputId;
var submitButton;

function openFileManager(rootFolder, inputId1, containerId, fileManagerId, fileManagerLayerId, submitButtonId)
{
	inputId = inputId1;
	submitButton = submitButtonId;

	$('#' + containerId).fadeOut(400, function() {
		
		fileManagerRootFolder    = rootFolder;
		fileManagerCurrentFolder = rootFolder;

			fileManagerBrowseFolder(fileManagerId, fileManagerCurrentFolder, 1, 1);

			$('#' + fileManagerLayerId).fadeIn(400, function() {
			
				// Get the dimensions of the browser window
	
				var winwidth = $(window).width();
				var winheight = $(window).height();
				
				// Get the dimensions of the layer
				var layerwidth = FileManagerDiv.clientWidth;
				var layerheight = FileManagerDiv.clientHeight;
				
				// Centre the layer
				FileManagerDiv.style.left = ((winwidth  - layerwidth)  / 2) + "px";
				FileManagerDiv.style.top  = ((winheight - layerheight) / 2) + "px";
			});
	});
}

//-----------------------------------------------------------------------------
// Function which closes file manager
//-----------------------------------------------------------------------------

function closeFileManager(applySettings, containerId, fileManagerId, fileManagerLayerId)
{
	if (applySettings == true)
	{
		if (inputId != null)
		{
			var s;

	    	var grid = jQuery("#" + fileManagerId);

	    	s = jQuery('#' + fileManagerId).jqGrid('getGridParam','selarrrow');

	    	var filenames = "";
	    	
	    	s.forEach(function(entry) {

	    		var fileData = grid.jqGrid('getRowData', entry);

	    		if (fileData["Type"] == '0')
		    	{
	    			if (filenames.length > 0)
	    			{
	    				filenames = filenames + ", ";
	    			}
	    			
	    			filenames = filenames + fileData["Filename"]; 
		    	}
		    	
	    	});
			
			$('#' + inputId).val(filenames);
			
			if (submitButton != null)
			{
				setSaveTimeout(submitButton);
				
				submitButton = null;
			}
		}
	}
	
	$('#' + fileManagerLayerId).fadeOut(400, function() {
		
			$('#' + containerId).fadeIn(400);
	});
}

///////////////////////////////////////////////////////////////////////////////
//
//
//
// EDIT ENTITY functions
//
//
//
///////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// Function which copies file name to clipboard
//-----------------------------------------------------------------------------

function entityUploadFile(baseElementId, baseElementIndex, submitButtonId)
{
	$("#" + baseElementIndex + "_files").change(function()
			{
				var filename =  $("#" + baseElementIndex + "_files").val();

				var idx = filename.lastIndexOf('/');
				
				if (idx == -1)
				{
					idx = filename.lastIndexOf('\\');
				}
				
				filename = filename.substring(idx + 1);
				
				$("#" + baseElementId + "_filename").val(filename);
				
				showElement(baseElementIndex + '_editImage');
				showElement(baseElementIndex + '_deleteImage');
				hideElement(baseElementIndex + '_uploadImage');

				$("#" + baseElementIndex + "_uploadFileButton").click();
				
				setSaveTimeout(submitButtonId);
				
			}).click();
}

//-----------------------------------------------------------------------------
// Function which starts editing of entity file
//-----------------------------------------------------------------------------

function entityEditFile(projectId, entityType, p1, textFieldId, textEditorId, textEditorCtrl)
{
	var entityName = $('#' + textFieldId).val();

	$('#' + textEditorId).fadeToggle(400);
	
	if($('#' + textEditorId).is(':visible'))
	{
		readEntityFile(projectId, entityType, entityName, p1, textEditorCtrl);
	}
}

//-----------------------------------------------------------------------------
// Function which saves entity file
//-----------------------------------------------------------------------------

function entitySaveFile(projectId, entityType, p1, textFieldId, textEditorId, editorCtrl)
{
	var entityName = $('#' + textFieldId).val();
	
	writeEntityFile(projectId, entityType, entityName, p1, editorCtrl);
	
	hideElement(textEditorId);
}


//-----------------------------------------------------------------------------
// Function which reads content of entity file
//-----------------------------------------------------------------------------

function readEntityFile(pId, eType, eName, p1, editorCtrl)
{
	$.ajax({    // ajax call starts
    	url     : 'jwe.pl', // JQuery loads serverside.php
    	type    : "POST",
        data    : "performAction=ReadFile&amp;pId=" + pId + "&amp;eType=" + eType + "&amp;eName=" + eName + "&amp;$1=" + p1,
        dataType: 'text', 
        
        success: function(data) // Variable data contains the data we get from serverside
        {
        	editorCtrl.getDoc().setValue(data);
        	editorCtrl.setSize("100%", 400);
        }
    });
}

//-----------------------------------------------------------------------------
// Function which writes content of entity file
//-----------------------------------------------------------------------------

function writeEntityFile(pId, eType, eName, p1, editorCtrl)
{
	var txt = encodeURIComponent(editorCtrl.getDoc().getValue());

	$.ajax({    // ajax call starts
    	url     : 'jwe.pl', // JQuery loads serverside.php
    	type    : "POST",
        data    : "performAction=WriteFile&amp;pId=" + pId + "&amp;eType=" + eType + "&amp;eName=" + eName + "&amp;$1=" + p1 + "&amp;$2=" + txt,
        dataType: 'text', 
        
        success: function(data) // Variable data contains the data we get from serverside
        {
        }
    });
}

//-----------------------------------------------------------------------------
// Function which deletes file from entity
//-----------------------------------------------------------------------------

function entityDeleteFile(baseId, selectedFileField, fileEditorId, submitButtonId)
{
	$('#' + selectedFileField).val('');

	hideElement(baseId + '_editImage');
	hideElement(baseId + '_deleteImage');
	showElement(baseId + '_uploadImage');

	hideElement(fileEditorId);
	
	setSaveTimeout(submitButtonId);
}

//-----------------------------------------------------------------------------
// Function which creates new project
//-----------------------------------------------------------------------------

function entityAddProject(pId, eType)
{
	var x;

	var eName = prompt("Please enter name of new " + eType, "");

	if (eName != null)
	{
		var location = 'jwe.pl?pId=' + pId + '&performAction=CreateEntity&eType=' + eType + '&eName=' + eName;
		window.open(location,"_self");
	}
}

//-----------------------------------------------------------------------------
//Function which creates new project
//-----------------------------------------------------------------------------

function entityAddEntity(pId, eTyp, project, addRowId, entityArrayValueId, parentItemIndex, submitButtonId, level)
{
	var x;

	var eNam = prompt("Please enter name of new " + eTyp, "");
	
	if (eNam == null)
	{
		return;
	}

	var filenames = $('#' + entityArrayValueId).val();

	filenames = filenames.substring(1, filenames.length - 1);
	
	if (filenames.length == 0)
	{
		filenames = eNam; 
		
		showElement(parentItemIndex + "_editImage");
	}
	else
	{
		filenames = filenames + ", " + eNam; 
	}

	filenames = "[" + filenames + "]";

	$('#' + entityArrayValueId).val(filenames); 
	
	
	var addRow = document.getElementById(addRowId);
	var addRowEditor = document.getElementById(addRowId + "Editor");
	var prevSibling = addRow.previousElementSibling;

	var parentId = 0;
	var newId = 0;
	
	var entity = "";
	var property = "";
	
	var id = addRow.id;

	var index999 = id.indexOf('999');
	
	parentId = id.substring(0, index999 - 1);
	
	if (prevSibling != null)
	{
		id = prevSibling.id;
		
		var tempStr = id.substring(index999);
		var tempSlice = tempStr.split("_");
		
		newId = (parseInt(tempSlice[0]) + 1) + '';  
		
		entity = tempSlice[1];
		property = tempSlice[2];
	}
	else
	{
		var tempStr = id.substring(index999);
		var tempSlice = tempStr.split("_");

		newId = '0';

		entity = tempSlice[1];
		property = tempSlice[2];
	}
	
	newId        = parentId + "_" + newId;

	newElementId = newId + "_" + entity + "_" + property;

	$.ajax({    // ajax call starts
    	url     : 'jwe.pl', // JQuery loads serverside.php
    	type    : "POST",
        data    : "performAction=AddEntity&amp;pId=" + pId + "&amp;eType=" + eTyp + "&amp;eName=" + eNam + "&amp;$1=" + project + "&amp;elId=" + newId + "&amp;entity=" + entity + "&amp;property=" + property + "&amp;entityArrayValueId=" + entityArrayValueId + "&amp;parentItemIndex=" + parentItemIndex + "&amp;level=" + (level + 1), // Send value of the clicked button
        dataType: 'text', 
        
        success: function(data) // Variable data contains the data we get from serverside
        {
			var tbody = addRow.parentElement;
			
			var parentTable2 = document.getElementById("projectSettingsTable");
			var tbody2 = parentTable2.children[0];

			var elem = addRow.cloneNode(true);
			var elem2 = addRowEditor.cloneNode(true);
			
			var html = $.parseHTML(data);
			
			var tr1 = html[0].innerHTML;
			var tr2 = html[1].innerHTML;

			elem.id = html[0].id;
			elem2.id = html[1].id;

			elem.innerHTML = tr1;
			elem2.innerHTML = tr2;
			
			elem.style.display = "";
			elem2.style.display = "";
			
			tbody.insertBefore(elem , addRow);		
			tbody.insertBefore(elem2, addRow);
			
			fileUploadIndex = 1;

			for (var i = 0; i < 30; i++)
			{
				var usedId = newId + "_" + i;
				var editorTextArea = document.getElementById(usedId + "_fileEditorTextArea");
				
				if (editorTextArea != null)
				{
					hideElement(usedId + '_editImage');
					hideElement(usedId + '_deleteImage');
					showElement(usedId + '_uploadImage');

					codeMirrorEditor[usedId] = CodeMirror.fromTextArea(editorTextArea, {
				         lineNumbers: true,
				         lineWrapping: true,
				         height: "400px",
				         mode: "text/html"
		  			});

					
					fileUploadIndex = fileUploadIndex + 1;

					var tr3 = tbody2.insertRow(-1);
					tr3.innerHTML = html[fileUploadIndex].innerHTML;
					
					registerSubmitForm(usedId + '_uploadFilesForm', '<h3>File is uploaded.</h3>', '', null, "1", "errorMessage");
				}
			}
			
			showElement(tbody.parentElement.id);
			
			setSaveTimeout(submitButtonId);
        }
    });
}

//-----------------------------------------------------------------------------
//Function which creates new project
//-----------------------------------------------------------------------------

function entityExpandEntity(elementId, link, position, index)
{
	toggleDisplay(elementId);
	

	$.ajax({    // ajax call starts
		url     : 'jwe.pl', // JQuery loads serverside.php
		type    : "POST",
		data    : "aaa=" + link, // Send value of the clicked button
		dataType: 'text', 
      
		success: function(data) // Variable data contains the data we get from serverside
		{
			var parentTable2 = document.getElementById("projectSettingsTable");
			var tbody2 = parentTable2.children[0];

			var html = $.parseHTML(data);
			
			var entityTable = html[0];
			var fileForms = html[1];
			
			var fileFormsTable = fileForms.children[0];
			var fileFormsTableBody = fileFormsTable.children[0];
			
			var el1 = document.getElementById(position);
			el1.innerHTML=entityTable.innerHTML;
			
			var fileUploadIndex = 0;

			for (var i = 0; i < 30; i++)
			{
				var usedId = index + "_" + i;
				var editorTextArea = document.getElementById(usedId + "_fileEditorTextArea");
				
				if (editorTextArea != null)
				{
					codeMirrorEditor[usedId] = CodeMirror.fromTextArea(editorTextArea, {
				         lineNumbers: true,
				         lineWrapping: true,
				         height: "400px",
				         mode: "text/html"
		  			});
					
					var tr3 = tbody2.insertRow(-1);
					tr3.innerHTML = fileFormsTableBody.children[fileUploadIndex].innerHTML;
					
					registerSubmitForm2(usedId + '_uploadFilesForm', '<h3>File is uploaded.</h3>', '', null, "1", "errorMessage");

					fileUploadIndex = fileUploadIndex + 1;
				}
			}
		}
	});
}


//-----------------------------------------------------------------------------
// Function which deletes project from project group
//-----------------------------------------------------------------------------

function entityDeleteProject(projectId, entityName)
{
	var answer = confirm("Do you really want to delete project?");
	
	if (answer == false)
	{
		return;
	}

	$.ajax({    // ajax call starts
    	url     : 'jwe.pl', // JQuery loads serverside.php
    	type    : "POST",
        data    : "performAction=DeleteProject&amp;pId=" + projectId + "&amp;eName=" + entityName,
        dataType: 'text', 
        
        success: function(data) // Variable data contains the data we get from serverside
        {
        	deleteTableRow(entityName);
        }
    });
}

//-----------------------------------------------------------------------------
// Function which deletes entity from the table
//-----------------------------------------------------------------------------

function entityDeleteEntity(entityRowId, entityRowEditorId, currentEntityValueId, entityArrayValueId, parentItemIndex, submitButtonId, projectId, entityType, p1, p2, p3, p4, p5, p6)
{
	var entityName = $('#' + currentEntityValueId).val();
	var filenames = $('#' + entityArrayValueId).val();

	filenames = filenames.substring(1, filenames.length - 1);
	
    var filenamesArray = filenames.split(",");

    var newFilenames = "[";
    
    filenamesArray.forEach(function(entry)
   		{
    		var currentEntityName = entry.trim();
    		
    		if (currentEntityName != entityName)
    		{
	    		if (newFilenames.length == 1)
	    		{
	    			newFilenames = newFilenames + currentEntityName; 
	    		}
	    		else
	    		{
	    			newFilenames = newFilenames + ", " + currentEntityName; 
	    		}
    		}
    	});
    
    newFilenames = newFilenames + "]";
    
    deleteTableRow(entityRowId);
	deleteTableRow(entityRowEditorId);

	$('#' + entityArrayValueId).val(newFilenames);
	
	if (newFilenames.length == 2)
	{
		hideElement(parentItemIndex + "_editImage");
	}
	
	$.ajax({    // ajax call starts
    	url     : 'jwe.pl', // JQuery loads serverside.php
    	type    : "POST",
        data    : "performAction=DeleteEntity&amp;pId=" + projectId + "&amp;eType=" + entityType + "&amp;eName=" + entityName + "&amp;$1=" + p1 + "&amp;$2=" + p2 + "&amp;$3=" + p3 + "&amp;$4=" + p4 + "&amp;$5=" + p5 + "&amp;$6=" + p6,
        dataType: 'text', 
        
        success: function(data) // Variable data contains the data we get from serverside
        {
        	setSaveTimeout(submitButtonId);
        }
    });
}

//-----------------------------------------------------------------------------
//Function which deletes file row from the entity table
//-----------------------------------------------------------------------------

function entityDeleteTableRow(entityRowId, submitButtonId)
{
	deleteTableRow(entityRowId);
	
	setSaveTimeout(submitButtonId);
}
