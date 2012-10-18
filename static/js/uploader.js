var dropZoneDefaultInnerHTML = "";
var dropZoneTransferInProgress = false;

function handleDropFileSelect(evt) {
	if(dropZoneTransferInProgress) return;

	var dropZone = document.getElementById("uploader");

	handleDragOver(evt);

	var files = evt.dataTransfer.files;
	var fileReader = new FileReader();
	var theFile = files[0];
	
	if(!theFile) return;
	
	dropZoneTransferInProgress = true;
	
	dropZone.innerHTML = 'Loading file';
	
	fileReader.onloadend = function (evtx) {
		fileUpload(theFile.name, new Uint8Array(evtx.target.result));
	};
	fileReader.readAsArrayBuffer(theFile);
}

function fileUpload(name, fileData) {	
	var dropZone = document.getElementById("uploader");
	dropZone.innerHTML = '<div class="container">Uploading<br /><div id="barUpload" style="margin-left: 50px; margin-right: 50px;" class="progress progress-striped"><div class="bar" style="width: 0%;"></div></div></div>';

	var xhr = new XMLHttpRequest();
	xhr.upload.addEventListener("loadstart", uploadStart, false);
	xhr.upload.addEventListener("progress", uploadProgress, false);
	xhr.upload.addEventListener("load", uploadComplete, false);
	xhr.onreadystatechange = function() {
		if(xhr.readyState == 4) {
			if(xhr.status == 200) {
				document.location.href = "/" + xhr.responseText;
			} else {
				setupDropZone();
				alert("Upload error: " + xhr.responseText);
			}
		}
	};
	xhr.open("PUT", "/api/create?"+escape(name));
	xhr.send(fileData);
}

function uploadStart(evt) { }

function uploadComplete(evt) { }

function uploadProgress(evt) {
	if(evt.lengthComputable) {
		$('#barUpload div.bar').css("width", ((evt.loaded / evt.total) * 100) + "%");
	}
}

function handleDragOver(evt) {
	if(dropZoneTransferInProgress) return;
	
    evt.stopPropagation();
    evt.preventDefault();
	
	var dropZone = document.getElementById("uploader");
	if(evt.type == "dragover") {
		dropZone.innerHTML = 'Drop file now to upload';
		dropZone.style.color = "#B333E5";
		dropZone.style.borderColor = "#B333E5";
	} else if(evt.type == "dragleave") {
		dropZone.innerHTML = dropZoneDefaultInnerHTML;
		dropZone.style.color = "";
		dropZone.style.borderColor = "";
	}

    evt.dataTransfer.dropEffect = (evt.type == "dragover" ? "copy" : "");
    dropZone.className = (evt.type == "dragover" ? "hover" : "");
}

function setupDropZone() {
	// Setup the dnd listeners.
	var dropZone = document.getElementById('uploader');

	dropZone.innerHTML = "Drag & drop files here to upload them";
	
	dropZoneDefaultInnerHTML = dropZone.innerHTML;
	
	dropZone.addEventListener("dragover", handleDragOver, false);
	dropZone.addEventListener("dragleave", handleDragOver, false);
	dropZone.addEventListener("drop", handleDropFileSelect, false);
}

setupDropZone();
