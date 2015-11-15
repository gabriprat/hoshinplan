class TextileEditorButtonLink extends TextileEditorButton
	    
class TextileEditorButtonImage extends TextileEditorButton
	
class TextileEditorButtonGoogleDrive extends TextileEditorButton
class TextileEditorButtonBox extends TextileEditorButton
class TextileEditorButtonDropBox extends TextileEditorButton


TextileEditor.setButtons(
    [
        new TextileEditorButton("ed_strong",     "bold",           "*",    "*",  "b", "Bold", "s"),
        new TextileEditorButton("ed_emphasis",   "italic",         "_",    "_",  "i", "Italicize", "s"),
        new TextileEditorButton("ed_underline",  "underline",      "+",    "+",  "u", "Underline", "s"),
        new TextileEditorButton("ed_strike",     "strikethrough",  "-",    "-",  "s", "Strikethrough", "s"),
        new TextileEditorButton("ed_ol",         "list-ol",        " # ",  "", ",", "Numbered List"),
        new TextileEditorButton("ed_ul",         "list-ul",        " * ",  "", ".", "Bulleted List"),
        new TextileEditorButton("ed_p",          "paragraph",      "p",    "", "p", "Paragraph"),
        new TextileEditorButton("ed_h1",         "h1",             "h1",   "", "1", "Header 1"),
        new TextileEditorButton("ed_h2",         "h2",             "h2",   "", "2", "Header 2"),
        new TextileEditorButton("ed_h3",         "h3",             "h3",   "", "3", "Header 3"),
        new TextileEditorButton("ed_h4",         "h4",             "h4",   "", "4", "Header 4"),
        new TextileEditorButton("ed_block",      "quote-left",     "bq",   "\n", "q", "Blockquote"),
        new TextileEditorButtonSeparator(),
        new TextileEditorButton("ed_dedent",     "dedent",        ")",    "\n", "]", "Outdent"),
        new TextileEditorButton("ed_indent",     "indent",         "(",    "\n", "[", "Indent"),
        new TextileEditorButton("ed_justifyl",   "align-left",     "<",    "\n", "l", "Left Justify"),
        new TextileEditorButton("ed_justifyc",   "align-center",   "=",    "\n", "e", "Center Text"),
        new TextileEditorButton("ed_justifyr",   "align-right",    ">",    "\n", "r", "Right Justify"),
        new TextileEditorButton("ed_justify",    "align-justify",  "<>",   "\n", "j", "Justify"),
        new TextileEditorButtonSeparator(),
        new TextileEditorButtonLink("ed_chain",   "chain",           "\"link text\":",   "", "k", "Link"),
        new TextileEditorButtonImage("ed_image", "image",          "!",    "", "g", "Image"),
        new TextileEditorButtonSeparator(),
        new TextileEditorButtonGoogleDrive("ed_google_drive",      "google-drive",     "",   "", "", "Google Drive link"),
        new TextileEditorButtonDropBox("ed_dropbox",      "dropbox",     "",   "", "", "Dropbox link"),
        new TextileEditorButtonBox("ed_box",      "box",     "",   "", "", "Box link")
    ]    
)



class MyTextileEditor extends TextileEditor
  prepareButton: (button)-> 
    if button.separator
      theButton           = document.createElement("span")
      theButton.className = "ed_sep"
      return theButton
            
    if button.standard
      theButton    = document.createElement("button")
      theButton.id = button.id
      theButton.setAttribute("class", "standard ic-" + button.display)
      theButton.setAttribute("tagStart", button.tagStart)
      theButton.setAttribute("tagEnd", button.tagEnd)
      theButton.setAttribute("open", button.open)
      if button instanceof TextileEditorButtonLink
        theButton.setAttribute("data-type", "link")
      if button instanceof TextileEditorButtonImage
        theButton.setAttribute("data-type", "image")
      if button instanceof TextileEditorButtonGoogleDrive
        theButton.setAttribute("data-type", "google-drive")
      if button instanceof TextileEditorButtonBox
        theButton.setAttribute("data-type", "box")
      if button instanceof TextileEditorButtonDropBox
        theButton.setAttribute("data-type", "dropbox")	 
    else
      return button

    theButton.accessKey = button.access
    theButton.title     = button.title
    return theButton
    
  # if clicked, no selected text, tag not open highlight button
  # (edAddTag)
  addTag: (button) ->
    unless button.tagEnd is "" or button.getAttribute("data-type")
      @openTags[@openTags.length] = button
      $(button).addClass("selected");

    return button
    
  # if clicked, no selected text, tag open lowlight button
  # (edRemoveTag)
  removeTag: (button) ->
    i = 0
    while i < @openTags.length
      if @openTags[i] is button
        @openTags.splice(button, 1)

        #var el = document.getElementById(button.id);
        #el.className = 'unselected';
        $(button).removeClass("selected");
      i++

    return undefined
    
  insertTag: (button, tagStart, tagEnd) ->
    that = this
    if button.getAttribute("data-type") == "link"
      `bootbox.dialog({
                      message: '<div class="row">  ' +
                          '<div class="col-md-12"> ' +
                          '<form class="form-horizontal" onsubmit=""> ' +
                          '<div class="form-group"> ' +
                          '<label class="col-md-4 control-label" for="name">Txt</label> ' +
                          '<div class="col-md-4"> ' +
                          '<input id="bbtitle" name="title" type="text" placeholder="Google" class="form-control input-md"/> ' +
                          '</div> </div>' +
			  '<div class="form-group"> ' +
                          '<label class="col-md-4 control-label" for="url">URL</label> ' +
                          '<div class="col-md-4"> ' +
                          '<input id="bburl" name="url" type="text" placeholder="http://www.google.com" class="form-control input-md"/> ' +
                          '</div> ' +
                          '</div> ' +
                          '</form> </div>  </div>',
                      buttons: {
			  cancel: {
			  	label: "Cancel"
			  },
                          main: {
                              label: "OK",
                              className: "btn-primary",
                              callback: function () {
				  MyTextileEditor.__super__.insertTag.apply(that, [button, '"' + $('#bbtitle').val() + '":' + $('#bburl').val() , ' ']);
                              }
                          }
                      }
                  }
              );`
    else if button.getAttribute("data-type") == "image"
      bootbox.prompt("URL", (result) ->    
      	MyTextileEditor.__super__.insertTag.apply that, [button, "!" + result + "!", ''] unless result == null
      );
    else if button.getAttribute("data-type") == "google-drive"
      launchGoogleDriveSelect($(that.canvas));
    else if button.getAttribute("data-type") == "box"
      launchBoxSelect($(that.canvas));
    else if button.getAttribute("data-type") == "dropbox"
      launchDropBoxSelect($(that.canvas));
    else
      super(button, tagStart, tagEnd)
	
window.MyTextileEditor = MyTextileEditor
