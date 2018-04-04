#!/usr/local/bin/wish

package require rest
package require json
package require Img

global knora_server
set knora_server "http://0.0.0.0:3333"

proc ue_init {} {
   lappend d + { }
   for {set i 0} {$i < 256} {incr i} {
      set c [format %c $i]
      set x %[format %02x $i]
      if {![string match {[a-zA-Z0-9]} $c]} {
         lappend e $c $x
         lappend d $x $c
      }
   }
   set ::ue_map $e
   set ::ud_map $d
}
ue_init
proc uencode {s} { string map $::ue_map $s }
proc udecode {s} { string map $::ud_map $s }


#
# Setting up the work window
#
wm client . {Knora-Administration}
wm minsize . 800 500
set sx [winfo screenheight .]
set sy [winfo screenwidth .]
wm geometry . [expr $sy - 200]x[expr $sx - 200]+100+100

#===============================================================================
# proc knora_get_ontologies {}
#
# returns: list of dicts
# [ {@id ontology-id @type IRI knora-api:lastModificationDate date @label string},…]
#-------------------------------------------------------------------------------
# query the Knora instance for a list of all Ontologies
#===============================================================================
proc knora_get_ontologies {} {
  global knora_server
  set res [rest::get $knora_server/v2/ontologies/metadata {} {
    method get
    format json
  }]
  set res [json::json2dict $res]
  set ontos [dict get $res knora-api:hasOntologies]
  return $ontos
}
#===============================================================================

proc knora_get_users {} {
  global knora_server
  set res [rest::get $knora_server/admin/users {} {
    method get
    format json
  }]
  set res [json::json2dict $res]
  set users [dict get $res users]
  return $users
}


proc get_ontology {} {
  global ontosel_box_w
  set ontosel_box_w [toplevel .ontosel -class Dialog]
  wm resizable $ontosel_box_w false false
  wm group $ontosel_box_w .
  wm title $ontosel_box_w "Select Ontology"
  wm transient $ontosel_box_w . ;#[winfo toplevel [winfo parent $ontosel_box_w]]
  wm overrideredirect $ontosel_box_w 1

  set button_frame_w [frame $ontosel_box_w.button_frame]
  set cancel_button_w [ttk::button $button_frame_w.cancel \
    -text "Cancel" \
    -command {
      destroy $ontosel_box_w
  }]
  set ok_button_w [ttk::button $button_frame_w.ok \
     -default active \
     -text "OK" \
     -command {
#         read_settings $settings_fname $incl_geom $incl_surfs $incl_lights
         destroy $ontosel_box_w
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

  pack $button_frame_w \
    -side top -fill x -expand true \
    -padx 5 -pady 5
    raise $ontosel_box_w

  tkwait visibility $ontosel_box_w
  tkwait visibility $ontosel_box_w

  set oldFocus [focus]
  set oldGrab [grab current $ontosel_box_w]
  if {$oldGrab != ""} {
	   set grabStatus [grab status $oldGrab]
  }
  grab $ontosel_box_w
  focus $ok_button_w

    return

}
#set ontolist_label [ttk::label .ontolist_label -text "Ontologies: none selected"]
#ttk::button .ontolist_sel -text "Select new ontology" -command {
#  get_ontology
#}
#pack $ontolist_label .ontolist_sel -anchor nw -padx 5 -pady 5


set tabs_w [ttk::notebook .tabs_w]

set users_w [ttk::frame $tabs_w.users]
set projects_w [ttk::frame $tabs_w.projects]
set ontologies_w [ttk::frame $tabs_w.ontologies]
set properties_w [ttk::frame $tabs_w.properties]

$tabs_w add $users_w -text "Users"
$tabs_w add $projects_w -text "Projects"
$tabs_w add $ontologies_w -text "Ontologies"

pack $tabs_w -fill both -expand 1

set users [knora_get_users]
puts $users

set userlist [ttk::treeview $users_w.userlist -columns [list last first id] -displaycolumns [list last first id]]
$userlist heading last -text Lastname
$userlist heading first -text Firstname
$userlist heading id -text Id

foreach user $users {
#  $userlist insert {} end -id [dict get $user id ] -text [dict get $user familyName]
  $userlist insert {} end -id [dict get $user id ] \
    -values [list [dict get $user familyName] [dict get $user givenName] [dict get $user id]]
}
pack $userlist -fill y -expand 1

#foreach user $users {
#  puts "===================="#
#  puts [dict get $user familyName]
#  puts "--------------------"
#}
