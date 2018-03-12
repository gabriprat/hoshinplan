#Textile Editor v0.2
#created by: dave olsen, wvu web services
#created on: march 17, 2007
#project page: slateinfo.blogs.wvu.edu
#
#inspired by:
# - Patrick Woods, http://www.hakjoon.com/code/38/textile-quicktags-redirect &
# - Alex King, http://alexking.org/projects/js-quicktags
#
#features:
# - supports: IE7, FF2, Safari2
# - ability to use "simple" vs. "extended" editor
# - supports all block elements in textile except footnote
# - supports all block modifier elements in textile
# - supports simple ordered and unordered lists
# - supports most of the phrase modifiers, very easy to add the missing ones
# - supports multiple-paragraph modification
# - can have multiple "editors" on one page, access key use in this environment is flaky
# - access key support
# - select text to add and remove tags, selection stays highlighted
# - seamlessly change between tags and modifiers
# - doesn't need to be in the body onload tag
# - can supply your own, custom IDs for the editor to be drawn around
#
# TODO:
# - a clean way of providing image and link inserts
# - get the selection to properly show in IE
#
#more on textile:
# - Textism, http://www.textism.com/tools/textile/index.php
# - Textile Reference, http://hobix.com/textile/


class TextileEditorButton

  constructor: (id, display, tagStart, tagEnd, access, title, sve, open) ->
    @id       = id        # used to name the toolbar button
    @display  = display   # label on button
    @tagStart = tagStart  # open tag
    @tagEnd   = tagEnd    # close tag
    @access   = access    # set to -1 if tag does not need to be closed
    @title    = title     # sets the title attribute of the button to give 'tool tips'
    @sve      = sve       # sve = simple vs. extended. add an 's' to make it show up in the simple toolbar
    @open     = open      # set to -1 if tag does not need to be closed
    @standard = true      # this is a standard button

window.TextileEditorButton = TextileEditorButton


class TextileEditorButtonSeparator

  constructor: (sve) ->
    @separator = true
    @sve       = sve

window.TextileEditorButtonSeparator = TextileEditorButtonSeparator

class TextileEditor

  @setButtons: (buttons) ->
    TextileEditor.buttons = buttons

  @addButton: (button) ->
    @getButtons().push(button)

  @getButtons: () ->
    TextileEditor.buttons || new Array()

  constructor: (canvas, view) ->
    toolbar           = document.createElement("div")
    toolbar.id        = "textile-toolbar-" + canvas
    toolbar.className = "textile-toolbar"

    @canvas = document.getElementById(canvas)
    @canvas.parentNode.insertBefore(toolbar, @canvas)
    @openTags = new Array()

    # Create the local Button array by assigning theButtons array to edButtons
    edButtons       = TextileEditor.getButtons()
    standardButtons = new Array()

    i = 0
    while i < edButtons.length
      thisButton = @prepareButton(edButtons[i])
      if view is "simple"
        if edButtons[i].sve is "s"
          toolbar.appendChild thisButton
          standardButtons.push thisButton
      else
        if typeof thisButton is "string"
          toolbar.innerHTML += thisButton
        else
          toolbar.appendChild thisButton
          standardButtons.push thisButton
      i++

    te = this
    buttons = toolbar.getElementsByTagName("button")

    i = 0
    while i < buttons.length
      unless buttons[i].onclick
        buttons[i].onclick = ->
          te.insertTag this
          return false

      buttons[i].tagStart       = buttons[i].getAttribute("tagStart")
      buttons[i].tagEnd         = buttons[i].getAttribute("tagEnd")
      buttons[i].open           = buttons[i].getAttribute("open")
      buttons[i].textile_editor = te
      buttons[i].canvas         = te.canvas
      i++

# draw individual buttons (edShowButton)
  prepareButton: (button) ->
    if button.separator
      theButton           = document.createElement("span")
      theButton.className = "ed_sep"
      return theButton

    if button.standard
      theButton    = document.createElement("button")
      theButton.id = button.id
      theButton.setAttribute("class", "standard")
      theButton.setAttribute("tagStart", button.tagStart)
      theButton.setAttribute("tagEnd", button.tagEnd)
      theButton.setAttribute("open", button.open)

      img     = document.createElement("img")
      img.src = button.display
      theButton.appendChild(img)
    else
      return button

    theButton.accessKey = button.access
    theButton.title     = button.title
    return theButton

# if clicked, no selected text, tag not open highlight button
# (edAddTag)
  addTag: (button) ->
    unless button.tagEnd is ""
      @openTags[@openTags.length] = button
      button.className = "selected"

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
        button.className = "unselected"
      i++

    return undefined

# see if there are open tags. for the remove tag bit...
# (edCheckOpenTags)
  checkOpenTags: (button) ->
    tag = 0
    i = 0
    while i < @openTags.length
      tag++  if @openTags[i] is button
      i++

    return (tag > 0) # tag found / not found

# insert the tag. this is the bulk of the code.
# (edInsertTag)
  insertTag: (button, tagStart, tagEnd) ->
    myField = button.canvas
    if tagStart
      button.tagStart = tagStart
      button.tagEnd = (if tagEnd then tagEnd else "\n")
    textSelected = false
    finalText = ""
    FF = false

    # grab the text that's going to be manipulated, by browser
    if document.selection # IE support
      myField.focus()

      sel = document.selection.createRange()

      # set-up the text vars
      beginningText = ""
      followupText = ""
      selectedText = sel.text

      # check if text has been selected
      textSelected = true  if sel.text.length > 0

      # set-up newline regex's so we can swap tags across multiple paragraphs
      newlineReplaceRegexClean = /\r\n\s\n/g
      newlineReplaceRegexDirty = "\\r\\n\\s\\n"
      newlineReplaceClean = "\r\n\n"
    else if myField.selectionStart or myField.selectionStart == 0 or myField.selectionStart == '0' # MOZ/FF/NS/S support
# figure out cursor and selection positions
      startPos = myField.selectionStart
      endPos = myField.selectionEnd
      cursorPos = endPos
      scrollTop = myField.scrollTop
      FF = true # note that is is a FF/MOZ/NS/S browser

      # set-up the text vars
      beginningText = myField.value.substring(0, startPos)
      followupText = myField.value.substring(endPos, myField.value.length)

      # check if text has been selected
      unless startPos is endPos
        textSelected = true
        selectedText = myField.value.substring(startPos, endPos)

      # set-up newline regex's so we can swap tags across multiple paragraphs
      newlineReplaceRegexClean = /\n\n/g
      newlineReplaceRegexDirty = "\\n\\n"
      newlineReplaceClean = "\n\n"

    # if there is text that has been highlighted...
    if textSelected

# set-up some defaults for how to handle bad new line characters
      newlineStart = ""
      newlineStartPos = 0
      newlineEnd = ""
      newlineEndPos = 0
      newlineFollowup = ""

      # set-up some defaults for how to handle placing the beginning and end of selection
      posDiffPos = 0
      posDiffNeg = 0
      mplier = 1

      # remove newline from the beginning of the selectedText.
      if selectedText.match(/^\n/)
        selectedText = selectedText.replace(/^\n/, "")
        newlineStart = "\n"
        newlineStartpos = 1

      # remove newline from the end of the selectedText.
      if selectedText.match(/\n$/g)
        selectedText = selectedText.replace(/\n$/g, "")
        newlineEnd = "\n"
        newlineEndPos = 1

      # no clue, i'm sure it made sense at the time i wrote it
      if followupText.match(/^\n/)
        newlineFollowup = ""
      else
        newlineFollowup = "\n\n"

      # first off let's check if the user is trying to mess with lists
      if (button.tagStart is " * ") or (button.tagStart is " # ")
        listItems = 0 # sets up a default to be able to properly manipulate final selection

        # set-up all of the regex's
        re_start = new RegExp("^ (\\*|\\#) ", "g")
        if button.tagStart is " # "
          re_tag = new RegExp(" \\# ", "g") # because of JS regex stupidity i need an if/else to properly set it up, could have done it with a regex replace though
        else
          re_tag = new RegExp(" \\* ", "g")
        re_replace = new RegExp(" (\\*|\\#) ", "g")

        # try to remove bullets in text copied from ms word **Mac Only!**
        re_word_bullet_m_s = new RegExp("• ", "g") # mac/safari
        re_word_bullet_m_f = new RegExp("∑ ", "g") # mac/firefox
        selectedText = selectedText.replace(re_word_bullet_m_s, "").replace(re_word_bullet_m_f, "")

        # if the selected text starts with one of the tags we're working with...
        if selectedText.match(re_start)

# if tag that begins the selection matches the one clicked, remove them all
          if selectedText.match(re_tag)
            finalText = beginningText + newlineStart + selectedText.replace(re_replace, "") + newlineEnd + followupText
            listItems = matches.length  if matches = selectedText.match(RegExp(" (\\*|\\#) ", "g"))
            posDiffNeg = listItems * 3 # how many list items were there because that's 3 spaces to remove from final selection

# else replace the current tag type with the selected tag type
          else
            finalText = beginningText + newlineStart + selectedText.replace(re_replace, button.tagStart) + newlineEnd + followupText

# else try to create the list type
# NOTE: the items in a list will only be replaced if a newline starts with some character, not a space
        else
          finalText = beginningText + newlineStart + button.tagStart + selectedText.replace(newlineReplaceRegexClean, newlineReplaceClean + button.tagStart).replace(/\n(\S)/g, "\n" + button.tagStart + "$1") + newlineEnd + followupText
          listItems = matches.length  if matches = selectedText.match(/\n(\S)/g)
          posDiffPos = 3 + listItems * 3

# now lets look and see if the user is trying to muck with a block or block modifier
      else if button.tagStart.match(/^(h1|h2|h3|h4|h5|h6|bq|p|\>|\<\>|\<|\=|\(|\))/g)
        insertTag           = ""
        insertModifier      = ""
        tagPartBlock        = ""
        tagPartModifier     = ""
        tagPartModifierOrig = "" # ugly hack but it's late
        drawSwitch          = ""
        captureIndentStart  = false
        captureListStart    = false
        periodAddition      = "\\. "
        periodAdditionClean = ". "
        listItemsAddition   = 0
        re_list_items       = new RegExp("(\\*+|\\#+)", "g") # need this regex later on when checking indentation of lists
        re_block_modifier   = new RegExp("^(h1|h2|h3|h4|h5|h6|bq|p| [\\*]{1,} | [\\#]{1,} |)(\\>|\\<\\>|\\<|\\=|[\\(]{1,}|[\\)]{1,6}|)", "g")

        if tagPartMatches = re_block_modifier.exec(selectedText)
          tagPartBlock = tagPartMatches[1]
          tagPartModifier = tagPartMatches[2]
          tagPartModifierOrig = tagPartMatches[2]
          tagPartModifierOrig = tagPartModifierOrig.replace(/\(/g, "\\(")

        # if tag already up is the same as the tag provided replace the whole tag
        if tagPartBlock is button.tagStart
          insertTag = tagPartBlock + tagPartModifierOrig # use Orig because it's escaped for regex
          drawSwitch = 0

# else if let's check to add/remove block modifier
        else if (tagPartModifier is button.tagStart) or (newm = tagPartModifier.match(/[\(]{2,}/g))
          if (button.tagStart is "(") or (button.tagStart is ")")
            indentLength = tagPartModifier.length
            if button.tagStart is "("
              indentLength = indentLength + 1
            else
              indentLength = indentLength - 1
            i = 0

            while i < indentLength
              insertModifier = insertModifier + "("
              i++
            insertTag = tagPartBlock + insertModifier
          else
            if button.tagStart is tagPartModifier
              insertTag = tagPartBlock
# going to rely on the default empty insertModifier
            else
              if button.tagStart.match(/(\>|\<\>|\<|\=)/g)
                insertTag = tagPartBlock + button.tagStart
              else
                insertTag = button.tagStart + tagPartModifier
          drawSwitch = 1

# indentation of list items
        else if listPartMatches = re_list_items.exec(tagPartBlock)
          listTypeMatch = listPartMatches[1]
          indentLength = tagPartBlock.length - 2
          listInsert = ""
          if button.tagStart is "("
            indentLength = indentLength + 1
          else
            indentLength = indentLength - 1
          if listTypeMatch.match(/[\*]{1,}/g)
            listType = "*"
            listReplace = "\\*"
          else
            listType = "#"
            listReplace = "\\#"
          i = 0

          while i < indentLength
            listInsert = listInsert + listType
            i++
          unless listInsert is ""
            insertTag = " " + listInsert + " "
          else
            insertTag = ""
          tagPartBlock = tagPartBlock.replace(/(\*|\#)/g, listReplace)
          drawSwitch = 1
          captureListStart = true
          periodAddition = ""
          periodAdditionClean = ""
          listItemsAddition = matches.length  if matches = selectedText.match(/\n\s/g)

# must be a block modification e.g. p>. to p<.
        else

# if this is a block modification/addition
          if button.tagStart.match(/(h1|h2|h3|h4|h5|h6|bq|p)/g)
            if tagPartBlock is ""
              drawSwitch = 2
            else
              drawSwitch = 1
            insertTag = button.tagStart + tagPartModifier

# else this is a modifier modification/addition
          else
            if (tagPartModifier is "") and (tagPartBlock isnt "")
              drawSwitch = 1
            else if tagPartModifier is ""
              drawSwitch = 2
            else
              drawSwitch = 1

            # if no tag part block but a modifier we need at least the p tag
            tagPartBlock = "p"  if tagPartBlock is ""

            #make sure to swap out outdent
            if button.tagStart is ")"
              tagPartModifier = ""
            else
              tagPartModifier = button.tagStart
              captureIndentStart = true # ugly hack to fix issue with proper selection handling
            insertTag = tagPartBlock + tagPartModifier
        mplier = 0
        if captureListStart or (tagPartModifier.match(/[\(\)]{1,}/g))
          re_start = new RegExp(insertTag.escape + periodAddition, "g") # for tags that mimic regex properties, parens + list tags
        else
          re_start = new RegExp(insertTag + periodAddition, "g") # for tags that don't, why i can't just escape everything i have no clue
        re_old = new RegExp(tagPartBlock + tagPartModifierOrig + periodAddition, "g")
        re_middle = new RegExp(newlineReplaceRegexDirty + insertTag.escape + periodAddition.escape, "g")
        re_tag = new RegExp(insertTag.escape + periodAddition.escape, "g")

        # *************************************************************************************************************************
        # this is where everything gets swapped around or inserted, bullets and single options have their own if/else statements
        # *************************************************************************************************************************
        if (drawSwitch is 0) or (drawSwitch is 1)
          if drawSwitch is 0 # completely removing a tag
            finalText = beginningText + newlineStart + selectedText.replace(re_start, "").replace(re_middle, newlineReplaceClean) + newlineEnd + followupText
            mplier = mplier + matches.length  if matches = selectedText.match(newlineReplaceRegexClean)
            posDiffNeg = insertTag.length + 2 + (mplier * 4)
          else # modifying a tag, though we do delete bullets here
            finalText = beginningText + newlineStart + selectedText.replace(re_old, insertTag + periodAdditionClean) + newlineEnd + followupText
            mplier = mplier + matches.length  if matches = selectedText.match(newlineReplaceRegexClean)

            # figure out the length of various elements to modify the selection position
            if captureIndentStart # need to double-check that this wasn't the first indent
              tagPreviousLength = tagPartBlock.length
              tagCurrentLength = insertTag.length
            else if captureListStart # if this is a list we're manipulating
              if button.tagStart is "(" # if indenting
                tagPreviousLength = listTypeMatch.length + 2
                tagCurrentLength = insertTag.length + listItemsAddition
              else if insertTag.match(/(\*|\#)/g) # if removing but still has bullets
                tagPreviousLength = insertTag.length + listItemsAddition
                tagCurrentLength = listTypeMatch.length
              else # if removing last bullet
                tagPreviousLength = insertTag.length + listItemsAddition
                tagCurrentLength = listTypeMatch.length - (3 * listItemsAddition) - 1
            else # everything else
              tagPreviousLength = tagPartBlock.length + tagPartModifier.length
              tagCurrentLength = insertTag.length
            if tagCurrentLength > tagPreviousLength
              posDiffPos = (tagCurrentLength - tagPreviousLength) + (mplier * (tagCurrentLength - tagPreviousLength))
            else
              posDiffNeg = (tagPreviousLength - tagCurrentLength) + (mplier * (tagPreviousLength - tagCurrentLength))
        else # for adding tags other then bullets (have their own statement)
          finalText = beginningText + newlineStart + insertTag + ". " + selectedText.replace(newlineReplaceRegexClean, button.tagEnd + "\n" + insertTag + ". ") + newlineFollowup + newlineEnd + followupText
          mplier = mplier + matches.length  if matches = selectedText.match(newlineReplaceRegexClean)
          posDiffPos = insertTag.length + 2 + (mplier * 4)

# swap in and out the simple tags around a selection like bold
      else
        mplier = 1 # the multiplier for the tag length
        re_start = new RegExp("^\\" + button.tagStart, "g")
        re_end = new RegExp("\\" + button.tagEnd + "$", "g")
        re_middle = new RegExp("\\" + button.tagEnd + newlineReplaceRegexDirty + "\\" + button.tagStart, "g")
        if selectedText.match(re_start) and selectedText.match(re_end)
          finalText = beginningText + newlineStart + selectedText.replace(re_start, "").replace(re_end, "").replace(re_middle, newlineReplaceClean) + newlineEnd + followupText
          mplier = mplier + matches.length  if matches = selectedText.match(newlineReplaceRegexClean)
          posDiffNeg = button.tagStart.length * mplier + button.tagEnd.length * mplier
        else
          finalText = beginningText + newlineStart + button.tagStart + selectedText.replace(newlineReplaceRegexClean, button.tagEnd + newlineReplaceClean + button.tagStart) + button.tagEnd + newlineEnd + followupText
          mplier = mplier + matches.length  if matches = selectedText.match(newlineReplaceRegexClean)
          posDiffPos = (button.tagStart.length * mplier) + (button.tagEnd.length * mplier)
      cursorPos += button.tagStart.length + button.tagEnd.length

# just swap in and out single values, e.g. someone clicks b they'll get a *
    else
      buttonStart = ""
      buttonEnd = ""
      re_p = new RegExp("(\\<|\\>|\\=|\\<\\>|\\(|\\))", "g")
      re_h = new RegExp("^(h1|h2|h3|h4|h5|h6|p|bq)", "g")
      if not @checkOpenTags(button) or button.tagEnd is "" # opening tag
        if button.tagStart.match(re_h)
          buttonStart = button.tagStart + ". "
        else
          buttonStart = button.tagStart
        if button.tagStart.match(re_p) # make sure that invoking block modifiers don't do anything
          finalText = beginningText + followupText
          cursorPos = startPos
        else
          finalText = beginningText + buttonStart + followupText
          @addTag button
          cursorPos = startPos + buttonStart.length
      else # closing tag
        if button.tagStart.match(re_p)
          buttonEnd = "\n\n"
        else if button.tagStart.match(re_h)
          buttonEnd = "\n\n"
        else
          buttonEnd = button.tagEnd
        finalText = beginningText + button.tagEnd + followupText
        @removeTag button
        cursorPos = startPos + button.tagEnd.length

    # set the appropriate DOM value with the final text
    if FF is true
      myField.value     = finalText
      myField.scrollTop = scrollTop
    else
      sel.text = finalText

    if textSelected
# build up the selection capture, doesn't work in IE
      myField.selectionStart = startPos + newlineStartPos
      myField.selectionEnd = endPos + posDiffPos - posDiffNeg - newlineEndPos

    else
      myField.selectionStart = cursorPos
      myField.selectionEnd   = cursorPos

window.TextileEditor = TextileEditor
