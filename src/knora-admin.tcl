#!/usr/local/bin/wish
# v2/authentication

global execdir
set execdir [file dirname $argv0]

package require rest
package require json
package require Img
package require xml
package require tooltip
package require aes

global knora_server ;# holds the server base url
set knora_server "http://0.0.0.0:3333"

global aeskey
set aeskey "ABCDEFGHIJKLMOPQ"

#
# here we include some library-type sources
#
source [file join $execdir "helper.tcl"]
source [file join $execdir "knora-api.tcl"]

source [file join $execdir "knora-admin-usertab.tcl"] ;# interface for user tab
source [file join $execdir "knora-admin-projecttab.tcl"] ;# interface for project tab



global username
set username "-"
global aespasswd
set aespasswd ""

global languages ;# list of supported languages
set languages [list de en fr it]

#*****************************************************************************
# proc startup_box {}
#
# returns: nothing
#-----------------------------------------------------------------------------
# Creates the startup dialog box and puts it onto the screen
#*****************************************************************************
proc startup_box {} {
  global private startup_box_w
  global private tmppasswd
  global private tmpusername
  global private login_error_l
  global http_code

  set tmpusername ""
  set tmppasswd ""
  set startup_box_w [toplevel .startup -class Dialog]
  wm resizable $startup_box_w false false
  wm sizefrom $startup_box_w program
  wm group $startup_box_w .
  wm transient $startup_box_w [winfo toplevel [winfo parent $startup_box_w]]
  wm title $startup_box_w "knora Administration Console 0.1.0 BETA"

  set geostr [wm geometry .]
  regexp {([0-9]*)x([0-9]*)(\+)([0-9]*)(\+)([0-9]*)} $geostr all width height p1 pos_x p2 pos_y
  set pos_x [expr $pos_x + $width / 2 - 200]
  set pos_y [expr $pos_y + $height / 2 - 100]
  wm geometry $startup_box_w "+$pos_x+$pos_y"

  set startup_label_w [label $startup_box_w.label \
    -text {  Knora Admin Console }]

  set startup_date_w [label $startup_box_w.date \
    -text "Version 0.1.0 BETA"]

  set startup_info1_w [label $startup_box_w.info1 \
    -wraplength 4i \
    -justify left \
    -text "Data and Service Center for the Humanities (DaSCH)"]

  set startup_info2_w [label $startup_box_w.info2 \
    -text {lukas.rosenthaler@unibas.ch}]

  set login_frame_w [frame $startup_box_w.frame \
    -relief sunken \
    -borderwidth 2]
  set login_user_l [label $login_frame_w.user_l -text "Username:"]
  set login_user_e [ttk::entry $login_frame_w.user_e -textvariable tmpusername]
  set login_passwd_l [label $login_frame_w.passwd_l -text "Password:"]
  set login_passwd_e [ttk::entry $login_frame_w.passwd_e  -show {*} -textvariable tmppasswd]
  set login_error_l [label $login_frame_w.error_l -foreground "red"]
  grid $login_user_l -column 0 -row 0
  grid $login_user_e -column 1 -row 0
  grid $login_passwd_l -column 0 -row 1
  grid $login_passwd_e -column 1 -row 1
  grid $login_error_l -column 0 -columnspan 2 -row 3

#  pack $login_label_w -fill x -expand 1 -side top
#  pack $login_frame_w -fill both -expand 1

  global private login_counter
  set login_counter 0
  set startup_dismiss_w [button $startup_box_w.dismiss \
    -text "OK" \
    -default active \
    -command {
      set username $tmpusername
      set aespasswd [aes::aes -dir encrypt -key $aeskey $tmppasswd]
      set res [knoraApi::authenticate]
      if { [dict exists $res errormsg] } {
        if { $login_counter < 3 } {
          $login_error_l configure -text [dict get $res errormsg]
        } else {
          exit
        }
      } else {
        set private(dismiss) 1
      }
      incr login_counter
    }]
  bind $startup_dismiss_w <Return> "
    $startup_dismiss_w configure -state active -relief sunken
    update idletasks
    after 100
    $startup_dismiss_w invoke
  "

  pack $startup_label_w \
    $startup_date_w \
  	$startup_info1_w \
    $startup_info2_w \
    $login_frame_w \
  	$startup_dismiss_w \
  	-side top -padx 5 -pady 5

  update idletask

  tkwait visibility $startup_box_w
  tkwait visibility $startup_dismiss_w

  set oldFocus [focus]
  set oldGrab [grab current $startup_box_w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $startup_box_w
  focus $startup_dismiss_w

  update idletask
#    after 2000 {
#	set private(dismiss) 1
#    }

  update idletask
  tkwait variable private(dismiss)

  catch {focus $oldFocus}
  catch {
    # It's possible that the window has already been destroyed,
  	# hence this "catch".  Delete the Destroy handler so that
  	# tkPriv(button) doesn't get reset by it.

    bind $startup_box_w <Destroy> {}
    destroy $startup_box_w
  }

  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }

  return
}
#=============================================================================

proc login_dialog {} {
  global private login_box_w
  global username

  set login_box_w [toplevel .settings -class Dialog]
  wm resizable $login_box_w false false
  wm group $login_box_w .
  wm sizefrom $login_box_w program
  wm transient $login_box_w [winfo toplevel [winfo parent $login_box_w]]

  set login_label_w [label $login_box_w.label \
      -text {  Login  }]
  set login_frame_w [frame $login_box_w.frame \
      -relief sunken \
      -borderwidth 2]
  set login_user_l [label $login_frame_w.user_l -text "Username:"]
  set login_user_e [ttk::entry $login_frame_w.user_e -textvariable tmpusername]
  set login_passwd_l [label $login_frame_w.passwd_l -text "Password:"]
  set login_passwd_e [ttk::entry $login_frame_w.passwd_e  -show {*} -textvariable tmppasswd]

  grid $login_user_l -column 0 -row 0
  grid $login_user_e -column 1 -row 0
  grid $login_passwd_l -column 0 -row 1
  grid $login_passwd_e -column 1 -row 1

  pack $login_label_w -fill x -expand 1 -side top
  pack $login_frame_w -fill both -expand 1

  set button_frame_w [frame $login_box_w.button_frame]
  set cancel_button_w [button $button_frame_w.cancel \
    -text "Cancel" \
    -command {
      destroy $login_box_w
    }]
    set ok_button_w [button $button_frame_w.ok \
      -text "OK" \
      -default active \
      -command {
        set username $tmpusername
        set aespasswd [aes::aes -dir encrypt -key $aeskey $tmppasswd]
#        write_settings $settings_fname $incl_geom $incl_surfs $incl_lights
        destroy $login_box_w
      }]
    bind $ok_button_w <Return> "
      $ok_button_w configure -state active -relief sunken
      update idletasks
      after 100
      $ok_button_w invoke
  	"

    grid columnconfigure $button_frame_w 0 -minsize 25
    grid columnconfigure $button_frame_w 1 -minsize 120
    grid columnconfigure $button_frame_w 2 -minsize 25
    grid columnconfigure $button_frame_w 3 -minsize 120
    grid columnconfigure $button_frame_w 4 -minsize 25
    grid $cancel_button_w -row 0 -column 1 -sticky we -pady 5
    grid $ok_button_w -row 0 -column 3 -sticky we -pady 5

    pack $button_frame_w -fill x -expand 1 -side bottom

    raise $login_box_w

    tkwait visibility $login_box_w
    tkwait visibility $ok_button_w

    set oldFocus [focus]
    set oldGrab [grab current $login_box_w]
    if {$oldGrab != ""} {
      set grabStatus [grab status $oldGrab]
    }
    grab $login_box_w
#    focus $ok_button_w

    return
}


#
# Setting up the window decoration
#
wm client . {Knora-Administration}
wm minsize . 800 500
set sx [winfo screenheight .]
set sy [winfo screenwidth .]
wm geometry . [expr $sy - 200]x[expr $sx - 200]+100+100

#
# show the startup message
#
tkwait visibility .
startup_box
update idletask

#
# build basic user interface using tab
#
set title_w [ttk::frame .title -padding 5]
image create photo logo -file [file join $execdir "icons" "knora-logo-small.png"]
set logo_w [ttk::label $title_w.logo -compound left -image logo -text "Admin Console" -relief raised -anchor center]
set header_w [ttk::frame .header -padding 5]
set login_label [ttk::label $header_w.login_label -text "User: "]
set login_name [ttk::label $header_w.login_name -textvariable username]
set login_button [ttk::button $header_w.login_button -text "login..." -command {
  login_dialog
}]

set tabs_w [ttk::notebook .tabs_w]

set users_w [ttk::frame $tabs_w.users]
set projects_w [ttk::frame $tabs_w.projects]
set ontologies_w [ttk::frame $tabs_w.ontologies]

$tabs_w add $users_w -text "Users"
$tabs_w add $projects_w -text "Projects"
$tabs_w add $ontologies_w -text "Ontologies"

pack $title_w $header_w -fill x -side top
pack $logo_w -fill x -expand 1
pack $login_label $login_name $login_button -side left
pack $tabs_w -fill both -expand 1 -side top

users_tab $users_w
projects_tab $projects_w
