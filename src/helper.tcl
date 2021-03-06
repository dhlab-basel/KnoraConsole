namespace eval helper {
  variable ue_map
  variable ud_map

  proc ue_init {} {
    variable ue_map
    variable ud_map
     lappend d + { }
     for {set i 0} {$i < 256} {incr i} {
        set c [format %c $i]
        set x %[format %02x $i]
        if {![string match {[a-zA-Z0-9]} $c]} {
           lappend e $c $x
           lappend d $x $c
        }
     }
     set ue_map $e
     set ud_map $d
  }

  ue_init

  proc uencode {s} {
    variable ue_map
    variable ud_map

    string map $ue_map $s
  }

  proc udecode {s} {
    variable ue_map
    variable ud_map

    string map $ud_map $s
  }

  proc parse_iri { iri } {
    set parts [split $iri "/"]
    return lmap part $parts { expr { $part == {} ? [continue] : $part} }
  }
  
  
  proc dict2json { data } {
     set json "\{"
     set i 0
     dict for {key value} $data {
        if { [expr $i > 0] } {
           set json [concat $json ", "]
        }
        set json [concat $json  "\"$key\"" ":" "\"$value\""]
        incr i
     }
     set json [concat $json "\}"]
     return $json
  }

  namespace export uencode udecode parse_iri dict2json
}
