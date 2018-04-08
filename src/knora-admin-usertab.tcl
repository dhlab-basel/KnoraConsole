
global field_status
proc field_changed {varname args} {
  global user_right
  set field_status($varname) 1
  $user_right.save configure -state normal
}


proc users_tab { users_w } {
  global knora_server
  global userlist
  global userarr
  global user_right
  global languages

  global familyNameV
  global givenNameV
  global emailV
  global passwordV

  set user_paned [ttk::panedwindow $users_w.paned -orient horizontal]
  set user_left [ttk::labelframe $user_paned.left  -text "Userlist"]
  set user_right [ttk::labelframe $user_paned.right -text "Details"]
  $user_paned add $user_left
  $user_paned add $user_right

  set users [knoraApi::get_users]
  foreach user $users {
    set userarr([dict get $user id]) $user
  }

  set userlist [ttk::treeview $user_left.userlist \
    -show headings \
    -selectmode browse \
    -columns [list last first id] \
    -displaycolumns [list last first id]]
  $userlist heading last -text Lastname
  $userlist heading first -text Firstname
  $userlist heading id -text Id
  bind $userlist <<TreeviewSelect>> {
    global userlist
    global userarr
    global user_right
    set uid [$userlist focus]
    set familyNameV [dict get $userarr($uid) familyName]
    set field_status(familyNameV) 0
    set givenNameV [dict get $userarr($uid) givenName]
    set field_status(givenNameV) 0
    set emailV [dict get $userarr($uid) email]
    set field_status(emailV) 0
    set passwordV {} ;# empty password field
    set field_status(passwordV) 0
    $user_right.langE configure -text [dict get $userarr($uid) lang]
    $user_right.save configure -state disabled

  }

  foreach user $users {
    set iri [dict get $user id]
    set id [lindex [helper::parse_iri $iri] end]
    $userlist insert {} end -id $iri \
      -values [list [dict get $user familyName] [dict get $user givenName] $iri]
  }
  pack $userlist -fill y -expand 1

  ttk::label $user_right.familyNameL -text "Lastname:"
  ttk::entry $user_right.familyNameE -textvariable familyNameV
  trace variable familyNameV w field_changed
  ttk::label $user_right.givenNameL -text "Firstname:"
  ttk::entry $user_right.givenNameE -textvariable givenNameV
  trace variable givenNameV w field_changed
  ttk::label $user_right.emailL -text "Email:"
  ttk::entry $user_right.emailE -textvariable emailV
  trace variable emailV w field_changed
  ttk::label $user_right.passwordL -text "Password:"
  ttk::entry $user_right.passwordE -show 0 -textvariable passwordV
  trace variable passwordV w field_changed
  ttk::label $user_right.langL -text "Language:"
  ttk::menubutton $user_right.langE -menu $user_right.langE.m -text "-"
  menu $user_right.langE.m

  foreach lang $languages {
    $user_right.langE.m add command -label $lang -command {}
  }

  ttk::button $user_right.save \
    -text "Save" \
    -state disabled \
    -command {}

    ttk::button $user_right.new \
      -text "new" \
      -command {}


  grid $user_right.familyNameL -column 0 -row 0 -sticky ne
  grid $user_right.familyNameE -column 1 -row 0 -sticky nw
  grid $user_right.givenNameL -column 0 -row 1 -sticky ne
  grid $user_right.givenNameE -column 1 -row 1 -sticky nw
  grid $user_right.emailL -column 0 -row 2 -sticky ne
  grid $user_right.emailE -column 1 -row 2 -sticky nw
  grid $user_right.passwordL -column 0 -row 3 -sticky ne
  grid $user_right.passwordE -column 1 -row 3 -sticky nw
  grid $user_right.langL -column 0 -row 4 -sticky ne
  grid $user_right.langE -column 1 -row 4 -sticky nw
  grid $user_right.save -column 0 -row 5 -sticky ne
  grid $user_right.new -column 1 -row 5 -sticky ne

  pack $user_paned -fill both -expand 1
}
