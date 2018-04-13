namespace eval knoraApi {
  global http_code

  #===============================================================================
  # proc authenticate {}
  #
  # returns: dicts
  # [ {@id ontology-id @type IRI knora-api:lastModificationDate date @label string},…]
  #-------------------------------------------------------------------------------
  # Test if a user/password pair is valid
  #===============================================================================
  proc authenticate { } {
    global knora_server
    global aeskey
    global username
    global aespasswd
    global authstr

    set passwd [aes::aes -dir decrypt -key $aeskey $aespasswd]
    set options [dict create method get error-body true auth "basic $username $passwd" format json ]
    catch { rest::get $knora_server/v2/authentication {} $options } res error
    if { [dict get $error "-code"] != 0} {
      return [dict create errormsg $res]
    }

    set res [json::json2dict $res]
    return $res
  }


  #===============================================================================
  # proc knora_get_ontologies {}
  #
  # returns: list of dicts
  # [ {@id ontology-id @type IRI knora-api:lastModificationDate date @label string},…]
  #-------------------------------------------------------------------------------
  # query the Knora instance for a list of all Ontologies
  #===============================================================================
  proc get_ontologies { } {
    global knora_server
    global aeskey
    global username
    global aespasswd
    global authstr
    set passwd [aes::aes -dir decrypt -key $aeskey $aespasswd]
    set options [dict create method get auth "basic $username $passwd" format json]

    catch { rest::get $knora_server/v2/ontologies/metadata {} $options } res error
    if { [dict get $error "-code"] != 0} {
      return [dict create errormsg $res]
    }

    set res [json::json2dict $res]
    set ontos [dict get $res knora-api:hasOntologies]
    return $ontos
  }
  #===============================================================================

  proc get_users { } {
    global knora_server
    global aeskey
    global username
    global aespasswd
    global authstr
    set passwd [aes::aes -dir decrypt -key $aeskey $aespasswd]
    set options [dict create method get auth "basic $username $passwd" format json]

    catch { rest::get $knora_server/admin/users {} $options } res error
    if { [dict get $error "-code"] != 0} {
      return [dict create errormsg $res]
    }

    set res [json::json2dict $res]
    set users [dict get $res users]
    return $users
  }
  #===============================================================================

  proc put_user { user_iri user_info} {
    global knora_server
    global aeskey
    global username
    global aespasswd
    global authstr
    set passwd [aes::aes -dir decrypt -key $aeskey $aespasswd]
    set options [dict create method put auth "basic $username $passwd" format json content-type "application/json"]

	set user_iri [::helper::uencode $user_iri]
#	set data [::json::write object {*}$user_info]
	set data [::helper::dict2json $user_info]
	puts "++++++++++++++++++++++"
	puts $data
	puts "++++++++++++++++++++++"
#	set data [::helper::uencode $data]

    catch { rest::put $knora_server/admin/users/$user_iri {} $options $data } res error
	puts "RES: =========================================="
	puts $res
	puts "ERROR: ========================================"
	puts $error
	puts "***********************************************"
    if { [dict get $error "-code"] != 0} {
      return [dict create errormsg $res]
    }

    set res [json::json2dict $res]
    set users [dict get $res users]
    return $users
  }
  #===============================================================================

  proc get_projects { } {
    global knora_server
    global aeskey
    global username
    global aespasswd
    global authstr
    set passwd [aes::aes -dir decrypt -key $aeskey $aespasswd]
    set options [dict create method get auth "basic $username $passwd" format json]

    catch { rest::get $knora_server/admin/projects {} $options } res error
    if { [dict get $error "-code"] != 0} {
      return [dict create errormsg $res]
    }

    set res [json::json2dict $res]
    set projects [dict get $res projects]
    return $projects
  }
  #===============================================================================

  proc get_ontologies { } {
    global knora_server
    global aeskey
    global username
    global aespasswd
    global authstr
    set passwd [aes::aes -dir decrypt -key $aeskey $aespasswd]
    set options [dict create method get auth "basic $username $passwd" format json]

    catch { rest::get $knora_server/admin/ontologies {} $options } res error
    if { [dict get $error "-code"] != 0} {
      return [dict create errormsg $res]
    }
    set res [json::json2dict $res]
    set ontologies [dict get $res ontologies]
    return $ontologies
  }
  #===============================================================================

  namespace export get_ontologies get_users get_projects get_ontologies
}
