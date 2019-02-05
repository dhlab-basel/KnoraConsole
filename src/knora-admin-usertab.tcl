
global languages

global usergroups
set usergroups [list UnknownUser KnownUser Creator ProjectMember ProjectAdmin SystemAdmin]

global fielddefs
set fielddefs [dict create \
    familyName [list entryfield "Lastname"] \
    givenName [list entryfield "Firstname"] \
    email [list entryfield "Email"] \
    username [list entryfield "Username"] \
    password [list passwdfield "Password"] \
    status [list checkbox "Status" "active"] \
    lang [list pulldown "Language" $languages] \
    id [list rdonlyfield "IRI"] \
]
# permissions [list tree "Groups p. project" $usergroups] \

;# groupsPerProject administrativePermissionsPerProject

#####################################################################################
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
#====================================================================================

#####################################################################################
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
#====================================================================================


#####################################################################################
proc users_tab { users_w } {
    global knora_server
    global userlist
    global user_right

    global fielddefs
    global field_status
    global orig_value
    global value
    global uid

    set user_paned [ttk::panedwindow $users_w.paned -orient horizontal]
    set user_left [ttk::labelframe $user_paned.left  -text "Userlist"]
    set user_right [ttk::labelframe $user_paned.right -text "Details"]
    $user_paned add $user_left
    $user_paned add $user_right

    set users [knoraApi::get_users]

    set userlist [ttk::treeview $user_left.userlist \
    -show headings \
    -selectmode browse \
    -columns [list id last first username email] \
    -displaycolumns [list last first username email]]
    $userlist heading last -text Lastname
    $userlist heading first -text Firstname
    $userlist heading email -text Email
    $userlist heading username -text Username
    bind $userlist <<TreeviewSelect>> {
        global userlist
        global user_right
        global field_status
        
        #
        # check if there are changes in the current user (bfore changing...)
        #
        set save false
        foreach { key val } [array get field_status ] {
            if { $val } {
                set save true
            }
        }
        if { $save } {
           set answer [tk_messageBox \
           -title "Alert" \
           -message "Unsaved changes! Change user anyway?" \
           -detail "Changing to a different user will invalidate all changes to the current user!" \
           -type okcancel]
           if { $answer == "cancel" } return
        }
        set uid [$userlist focus]
        set user [knoraApi::get_users $uid]
        dict for {fieldname fieldinfo} $fielddefs {
            set value($fieldname) [dict get $user $fieldname]
            set orig_value($fieldname) $value($fieldname)
            set field_status($fieldname) 0
            switch [lindex $fieldinfo 0] {
                entryfield {}
                passwdfield {}
                pulldown {
                    set value($fieldname) [dict get $user $fieldname]
                    set orig_value($fieldname) $value($fieldname)
                    set field_status($fieldname) 0
                    $user_right.${fieldname}E configure -text [dict get $user lang]
                }
            }
            if { [lindex $fieldinfo 0] != "rdonlyfield"} {
               $user_right.${fieldname}S configure -state disabled
            }
        }
        $user_right.save configure -state disabled
    }

    #
    # build list of all users
    #
    foreach user $users {
        set iri [dict get $user id]
        set id [lindex [helper::parse_iri $iri] end]
        $userlist insert {} end -id $iri \
        -values [list $iri [dict get $user familyName] [dict get $user givenName] [dict get $user email] [dict get $user username]]
    }
    pack $userlist -fill y -expand 1

    dict for {fieldname fieldinfo} $fielddefs {
        switch [lindex $fieldinfo 0] {
           rdonlyfield {
               ttk::label $user_right.${fieldname}L -text [lindex $fieldinfo 1]
               ttk::entry $user_right.${fieldname}E -textvariable value($fieldname) -state readonly
           }
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
                tk_optionMenu $user_right.${fieldname}E value($fieldname) {*}[lindex $fieldinfo 2]
                ttk::button $user_right.${fieldname}S -text {undo} -command "undo $fieldname"
                trace variable value($fieldname) w field_changed
            }
            checkbox {
               ttk::label $user_right.${fieldname}L -text [lindex $fieldinfo 1]
               ttk::checkbutton $user_right.${fieldname}E -text [lindex $fieldinfo 2] \
               -onvalue true \
               -offvalue false \
               -variable value($fieldname)
               ttk::button $user_right.${fieldname}S -text {undo} -command "undo $fieldname"
               trace variable value($fieldname) w field_changed
            }
            checkboxes {
               ttk::label $user_right.${fieldname}L -text [lindex $fieldinfo 1]
               ttk::frame $user_right.${fieldname}E
               foreach group [lindex $fieldinfo 2] {
                  puts $user_right.${fieldname}E.cb${group}
                  ttk::checkbutton $user_right.${fieldname}E.cb${group} -text $group
                  pack $user_right.${fieldname}E.cb${group} -side top -expand 1 -anchor nw
               }
               ttk::button $user_right.${fieldname}S -text {undo} -command "undo $fieldname"
               trace variable value($fieldname) w field_changed
            }
        }
    }

    ttk::button $user_right.save \
    -text "Save" \
    -state disabled \
    -command {
       foreach {field status} [array get field_status] {
          if { $status } {
             dict set changes $field $value($field)
          }
       }
       puts $changes
       knoraApi::put_user $uid $changes
       puts $uid
    }

    ttk::button $user_right.new \
    -text "new" \
    -command {}

    set i 0
    dict for {fieldname fieldinfo} $fielddefs {
        grid $user_right.${fieldname}L -column 0 -row $i -sticky ne
        grid $user_right.${fieldname}E -column 1 -row $i -sticky nw
        if { [lindex $fieldinfo 0] != "rdonlyfield" } {
           grid $user_right.${fieldname}S -column 2 -row $i -sticky sw
        }
        incr i
    }
#    grid $user_right.langL -column 0 -row 4 -sticky ne
#    grid $user_right.langE -column 1 -row 4 -sticky nw
    grid $user_right.save -column 0 -row $i -sticky ne
    grid $user_right.new -column 1 -row $i -sticky ne

    pack $user_paned -fill both -expand 1
    
    tkwait visibility $userlist
    #
    # set focus to first user
    #
    set tmpuser [lindex $users 0]
    set iri [dict get $tmpuser id]
    $userlist selection set [list $iri]
    $userlist focus $iri

}
#====================================================================================
