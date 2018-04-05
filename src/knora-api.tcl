namespace eval knoraApi {

  #===============================================================================
  # proc knora_get_ontologies {}
  #
  # returns: list of dicts
  # [ {@id ontology-id @type IRI knora-api:lastModificationDate date @label string},…]
  #-------------------------------------------------------------------------------
  # query the Knora instance for a list of all Ontologies
  #===============================================================================
  proc get_ontologies { knora_server } {
    set res [rest::get $knora_server/v2/ontologies/metadata {} {
      method get
      format json
    }]
    set res [json::json2dict $res]
    set ontos [dict get $res knora-api:hasOntologies]
    return $ontos
  }
  #===============================================================================

  proc get_users { knora_server } {
    set res [rest::get $knora_server/admin/users {} {
      method get
      format json
    }]
    set res [json::json2dict $res]
    set users [dict get $res users]
    return $users
  }

  namespace export get_ontologies get_users
}
