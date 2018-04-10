
global languages

global fielddefs
set fielddefs [dict create \
    familyName [list entryfield "Lastname"] \
    givenName [list entryfield "Firstname"] \
    email [list entryfield "Email"] \
    password [list passwdfield "Password"] \
    lang [list pulldown "Language" $languages]
]


#
# the proc is called if an entry field is being changed
#
proc field_changed {varname args} {
    global user_right
    global orig_value
    global field_status

    set fieldname [lindex $args 0]
    set field_status($fieldname) true
    $user_right.save configure -state normal
    $user_right.${fieldname}S configure -state normal
}

proc undo { fieldname } {
    global fielddefs
    global user_right
    global orig_value
    global field_status
    global value

    set fieldinfo [dict get $fielddefs $fieldname]
    switch [lindex $fieldinfo 0] {
        entryfield {}
        passwdfield {}
        pulldown {
            $user_right.${fieldname}E configure -text $orig_value($fieldname)
        }
    }
    set value($fieldname) $orig_value($fieldname)
    $user_right.${fieldname}S configure -state disabled
    set field_status($fieldname) 0
    
    set save false
    foreach { key val } [array get field_status ] {
        if { $val } {
            set save true
        }
    }
    if { !$save } {
        $user_right.save configure -state disable
    }
}


proc users_tab { users_w } {
    global knora_server
    global userlist
    global userarr
    global user_right
    
    global fielddefs
    global field_status
    global orig_value
    global value
        
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
        
        dict for {fieldname fieldinfo} $fielddefs {
            set value($fieldname) [dict get $userarr($uid) $fieldname]
            set orig_value($fieldname) $value($fieldname)
            set field_status($fieldname) 0
            switch [lindex $fieldinfo 0] {
                entryfield {}
                passwdfield {}
                pulldown {
                    set value($fieldname) [dict get $userarr($uid) $fieldname]
                    set orig_value($fieldname) $value($fieldname)
                    set field_status($fieldname) 0
                    $user_right.${fieldname}E configure -text [dict get $userarr($uid) lang]
                }
            }
            $user_right.${fieldname}S configure -state disabled
        }
        $user_right.save configure -state disabled
    }
    
    foreach user $users {
        set iri [dict get $user id]
        set id [lindex [helper::parse_iri $iri] end]
        $userlist insert {} end -id $iri \
        -values [list [dict get $user familyName] [dict get $user givenName] $iri]
    }
    pack $userlist -fill y -expand 1
    
    dict for {fieldname fieldinfo} $fielddefs {
        switch [lindex $fieldinfo 0] {
            entryfield {
                ttk::label $user_right.${fieldname}L -text [lindex $fieldinfo 1]
                ttk::entry $user_right.${fieldname}E -textvariable value($fieldname)
                ttk::button $user_right.${fieldname}S -text {undo} -command "undo $fieldname"
                trace variable value($fieldname) w field_changed
            }
            passwdfield {
                ttk::label $user_right.${fieldname}L -text [lindex $fieldinfo 1]
                ttk::entry $user_right.${fieldname}E -textvariable value($fieldname) -show {*}
                ttk::button $user_right.${fieldname}S -text {undo} -command "undo $fieldname"
                trace variable value($fieldname) w field_changed
            }
            pulldown {
                ttk::label $user_right.${fieldname}L -text [lindex $fieldinfo 1]
                ttk::menubutton $user_right.${fieldname}E -menu $user_right.${fieldname}E.m -text "-"
                menu $user_right.${fieldname}E.m
    
                foreach lang [lindex $fieldinfo 2] {
                    $user_right.${fieldname}E.m add command -label $lang -command "
                    set value($fieldname) $lang
                    $user_right.${fieldname}E configure -text $lang
                    "
                }
                ttk::button $user_right.${fieldname}S -text {undo} -command "undo $fieldname"
                trace variable value($fieldname) w field_changed
            }
        }
    }

    
    ttk::button $user_right.save \
    -text "Save" \
    -state disabled \
    -command {}
    
    ttk::button $user_right.new \
    -text "new" \
    -command {}
    
    set i 0
    dict for {fieldname fieldinfo} $fielddefs {
        grid $user_right.${fieldname}L -column 0 -row $i -sticky ne
        grid $user_right.${fieldname}E -column 1 -row $i -sticky nw
        grid $user_right.${fieldname}S -column 2 -row $i -sticky nw
        incr i
    }
    grid $user_right.langL -column 0 -row 4 -sticky ne
    grid $user_right.langE -column 1 -row 4 -sticky nw
    grid $user_right.save -column 0 -row 5 -sticky ne
    grid $user_right.new -column 1 -row 5 -sticky ne
    
    pack $user_paned -fill both -expand 1
    
    set json [::json::write object gaga GAGA gugus 5 ARR [::json::write arra AA BB CC DD]]
    puts $json
}
