proc users_tab { users_w } {
  global knora_server
  global userlist
  global userarr
  global user_right

  set user_paned [ttk::panedwindow $users_w.paned -orient horizontal]
  set user_left [ttk::labelframe $user_paned.left  -text "Userlist"]
  set user_right [ttk::labelframe $user_paned.right -text "Details"]
  $user_paned add $user_left
  $user_paned add $user_right

  set users [knoraApi::get_users $knora_server]
  foreach user $users {
    dict for {key val} $user {
      puts "$key : $val"
    }
    set userarr([dict get $user id]) $user
    puts "==========================================================="
  }

  set userlist [ttk::treeview $user_left.userlist \
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
    set givenNameV [dict get $userarr($uid) givenName]
    set emailV [dict get $userarr($uid) email]
    set passwordV {} ;# empty password field
    switch [dict get $userarr($uid) lang] {
      en {
        $user_right.langE configure -text "en"
      }
      de {
        $user_right.langE configure -text "de"
      }
      fr {
        $user_right.langE configure -text "fr"
      }
      it {
        $user_right.langE configure -text "it"
      }
    }
    puts $userarr($uid)
  }

  foreach user $users {
  #  $userlist insert {} end -id [dict get $user id ] -text [dict get $user familyName]
    $userlist insert {} end -id [dict get $user id ] \
      -values [list [dict get $user familyName] [dict get $user givenName] [dict get $user id]]
  }
  pack $userlist -fill y -expand 1

  ttk::label $user_right.familyNameL -text Lastname
  ttk::entry $user_right.familyNameE -textvariable familyNameV
  ttk::label $user_right.givenNameL -text Firstname
  ttk::entry $user_right.givenNameE -textvariable givenNameV
  ttk::label $user_right.emailL -text Email
  ttk::entry $user_right.emailE -textvariable emailV
  ttk::label $user_right.passwordL -text Password
  ttk::entry $user_right.passwordE -show 0 -textvariable passwordV
  ttk::label $user_right.langL -text Language
  ttk::menubutton $user_right.langE -menu $user_right.langE.m -text "-"
  menu $user_right.langE.m
  $user_right.langE.m add command -label "en" -command {}
  $user_right.langE.m add command -label "de"
  $user_right.langE.m add command -label "fr"
  $user_right.langE.m add command -label "it"

  grid $user_right.familyNameL -column 0 -row 0
  grid $user_right.familyNameE -column 1 -row 0
  grid $user_right.givenNameL -column 0 -row 1
  grid $user_right.givenNameE -column 1 -row 1
  grid $user_right.emailL -column 0 -row 2
  grid $user_right.emailE -column 1 -row 2
  grid $user_right.passwordL -column 0 -row 3
  grid $user_right.passwordE -column 1 -row 3
  grid $user_right.langL -column 0 -row 4
  grid $user_right.langE -column 1 -row 4

  pack $user_paned -fill both -expand 1
}
