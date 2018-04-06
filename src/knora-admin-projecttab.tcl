proc projects_tab { projects_w } {
  global knora_server
  global projectlist
  global projectarr
  global project_right

  set project_paned [ttk::panedwindow $projects_w.paned -orient horizontal]
  set project_left [ttk::labelframe $project_paned.left  -text "Projects"]
  set project_right [ttk::labelframe $project_paned.right -text "Details"]
  $project_paned add $project_left
  $project_paned add $project_right

  set projects [knoraApi::get_projects]
  foreach project $projects {
    set projectarr([dict get $project id]) $project
  }
  set projectlist [ttk::treeview $project_left.projectlist \
    -show headings \
    -selectmode browse \
    -columns [list shortname longname shortcode id] \
    -displaycolumns [list shortname longname shortcode id]]
  $projectlist heading shortname -text Shortname
  $projectlist heading longname -text Longname
  $projectlist heading shortcode -text Shortcode
  $projectlist heading id -text Id

  #---------------------------------------------------------------------------
  bind $projectlist <<TreeviewSelect>> {
    global projectlist
    global projectarr
    global project_right
    global languages

    set uid [$projectlist focus]
    set shortnameV [dict get $projectarr($uid) shortname]
    set longnameV [dict get $projectarr($uid) longname]
    set shortcodeV [dict get $projectarr($uid) shortcode]
    if { [info exists descriptionV]} { unset descriptionV }
    foreach descr [dict get $projectarr($uid) description] {
      if { [dict exists $descr language] } {
        set lang [dict get $descr language]
      } else {
        set lang "de"
      }
      set descriptionV($lang) [dict get $descr value]
    }
    set ontologiesV [dict get $projectarr($uid) ontologies]
    set keywordsV [dict get $projectarr($uid) keywords]

    #
    # fill text widget
    #
    $project_right.descriptionE delete 1.0 end
    foreach lang $languages {
      if { [info exists descriptionV($lang)] } {
        $project_right.descriptionE insert 1.0 $descriptionV($lang)
        break
      }
    }
    destroy [winfo children $project_right.ontologiesE]

    set i 0
    foreach ontology $ontologiesV {
      ttk::label $project_right.ontologiesE.$i -text [dict get $ontology ontologyName]
      grid $project_right.ontologiesE.$i -column 1 -row $i -sticky nw
      incr i
    }
    $project_right.keywordsE.list delete 0 end
    foreach keyword $keywordsV {
      $project_right.keywordsE.list insert end $keyword
    }

  }
  #-----------------------------------------------------------------------------

  foreach project $projects {
    $projectlist insert {} end -id [ dict get $project id ] \
      -values [list [dict get $project shortname] \
        [dict get $project longname] \
        [dict get $project shortcode]\
        [dict get $project id]]
  }
  pack $projectlist -fill y -expand 1

  ttk::label $project_right.shortnameL -text "Shortname:"
  ttk::entry $project_right.shortnameE -textvariable shortnameV
  ttk::label $project_right.longnameL -text "Longname:"
  ttk::entry $project_right.longnameE -textvariable longnameV
  ttk::label $project_right.shortcodeL -text "Shortcode:"
  ttk::entry $project_right.shortcodeE -textvariable shortcodeV
  ttk::label $project_right.descriptionL -text "Description:"
  text $project_right.descriptionE -height 8 -width 60 -undo 1 -wrap word
  ttk::label $project_right.ontologiesL -text "Ontologies:"
  ttk::frame $project_right.ontologiesE
  ttk::label $project_right.keywordsL -text "Keywords:"
  ttk::frame $project_right.keywordsE
  ttk::scrollbar $project_right.keywordsE.sb \
    -orient vertical \
    -command "$project_right.keywordsE.list yview"
  listbox $project_right.keywordsE.list \
    -yscroll "$project_right.keywordsE.sb set" \
    -setgrid 1 -height 4 -selectmode multip
  pack $project_right.keywordsE.sb -side right -fill y
	pack $project_right.keywordsE.list -side left -expand 1 -fill both -padx 5 -pady 5

  grid $project_right.shortnameL -column 0 -row 0 -sticky ne
  grid $project_right.shortnameE -column 1 -row 0 -sticky nw
  grid $project_right.longnameL -column 0 -row 1 -sticky ne
  grid $project_right.longnameE -column 1 -row 1 -sticky nw
  grid $project_right.shortcodeL -column 0 -row 2 -sticky ne
  grid $project_right.shortcodeE -column 1 -row 2 -sticky nw
  grid $project_right.descriptionL -column 0 -row 3 -sticky ne
  grid $project_right.descriptionE -column 1 -row 3 -sticky nw -padx 2 -pady 2
  grid $project_right.ontologiesL -column 0 -row 4 -sticky ne
  grid $project_right.ontologiesE -column 1 -row 4 -sticky nw -padx 2 -pady 2
  grid $project_right.keywordsL -column 0 -row 5 -sticky ne
  grid $project_right.keywordsE -column 1 -row 5 -sticky nw

  pack $project_paned -fill both -expand 1
}
