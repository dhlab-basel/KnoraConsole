#!/usr/local/bin/wish

package require rest
package require json
package require Img
package require xml

source "helper.tcl"
source "knora-api.tcl"

source "knora-admin-usertab.tcl"

global knora_server
set knora_server "http://0.0.0.0:3333"

#
# Setting up the work window
#
wm client . {Knora-Administration}
wm minsize . 800 500
set sx [winfo screenheight .]
set sy [winfo screenwidth .]
wm geometry . [expr $sy - 200]x[expr $sx - 200]+100+100




#set ontolist_label [ttk::label .ontolist_label -text "Ontologies: none selected"]
#ttk::button .ontolist_sel -text "Select new ontology" -command {
#  get_ontology
#}
#pack $ontolist_label .ontolist_sel -anchor nw -padx 5 -pady 5


set tabs_w [ttk::notebook .tabs_w]

set users_w [ttk::frame $tabs_w.users]
set projects_w [ttk::frame $tabs_w.projects]
set ontologies_w [ttk::frame $tabs_w.ontologies]
#set properties_w [ttk::frame $tabs_w.properties]

$tabs_w add $users_w -text "Users"
$tabs_w add $projects_w -text "Projects"
$tabs_w add $ontologies_w -text "Ontologies"

pack $tabs_w -fill both -expand 1


users_tab $users_w
#pack $user_left $user_right -fill both -expand 1

#foreach user $users {
#  puts "===================="#
#  puts [dict get $user familyName]
#  puts "--------------------"
#}
