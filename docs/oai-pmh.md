# OAI-PMH static implementation

[Open Archives Initiative](http://www.openarchives.org/) develops a set of interoperability standards used in cultural heritage repositories to facilitate aggregation and harvesting of metadata.
[OAI-PMH](http://www.openarchives.org/OAI/openarchivesprotocol.html) is a standard built into most digital collection repository platforms that requires a server to process a specific set of requests and provide an XML response.
However, OAI-PMH also specifies a "static repository" implementation intended for smaller collections (less than 5000 records) without processing OAI-PMH requests. 

A "Static Repository" is an XML file following the spec describing the collection published at a persistent URL. 

The Static Repository is made available to harvesters via a single "Static Repository Gateway" which is a server which can respond to OAI-PMH requests, but uses the information in the "Static Repository" to answer.

CollectionBuilder implements the XML template for a Static Repository. 
Users will need to investigate the arrangement for registering with a Gateway.

## Static Repository File

CollectionBuilder implementation of the "Static Repository" is the "oai.xml" file in the "utilities" directory.
The file is only generated during production environment build.

Configuration:

- Set `gateway-baseurl` in "oai.xml" front matter: `oai:baseURL` is required for the static repository to be valid, following the pattern Gateway-url + Static-repository-url (without the protocol), 
  e.g. if the Gateway is "http://gateway.institution.org/oai/" and the static repository is at "http://example.org/ma/mini.xml", the oai:baseURL is `http://gateway.institution.org/oai/example.org/ma/mini.xml`.
  The template automatically calculates the static repository location, but requires a valid `gateway-baseurl` to be set in the oai.xml front matter.
- Set `admin-email` in "oai.xml" front matter: a `oai:adminEmail` is required. Please set the `admin-email` in the oai.xml front matter to your valid contact email.
- Set `dc_map` fields in "config-metadata.csv": OAI XML uses their own version of basic Dublin Core metadata ([oai_dc spec](http://www.openarchives.org/OAI/2.0/oai_dc.xsd)) as a base for records.
  This allows only the fields: dc:title, dc:creator, dc:subject, dc:description, dc:publisher, dc:contributor, dc:date, dc:type, dc:format, dc:identifier, dc:source, dc:language, dc:relation, dc:coverage, dc:rights.
  The oai.xml template will iterate over all items using the `dc_map` of fields listed in `site.config-metadata`. 
  It will compare dc_map (which are given in format like `DCTERMS.title`) with the available oai_dc terms. 
  E.g. if you have `DCTERMS.creator` in dc_map, it will fill in `<dc:creator>` in the XML. 

Notes: 

- must have "oai-identifier" following pattern `oai:domain-name:local-identifier`, e.g. `oai:foo.org:some-local-id-53`. In CB context this is translated as: `oai:{{ site.url | remove: 'https://' }}:{{ site.baseurl | remove: '/' }}/{{ item.objectid }}`
- Specification for an OAI Static Repository and an OAI Static Repository Gateway, http://www.openarchives.org/OAI/2.0/guidelines-static-repository.htm
- Static Repository XML schema, http://www.openarchives.org/OAI/2.0/static-repository.xsd

## Static Repository Gateway

The "static repository" must be intermediated by a Gateway that responds to OAI-PMH requests. 
Gateways are currently beyond the scope of the CollectionBuilder implementation. 
Users will have to make arrangements to be registered with a Gateway to complete the OAI-PMH functionality.

A "static repository" must be registered with only one Gateway.
Access to harvesting will be via the Gateway, following pattern 
`gateway-url/oai/static-repository-url`, 
e.g. `http://gateway.institution.org/oai/an.oai.org/ma/mini.xml`.

To set up a new "static repository", need to initiate by sending a request:
`<Static Repository Gateway URL>?initiate=<Static Repository URL>`, 
e.g. `http://gateway.institution.org/oai?initiate=http://an.oai.org/ma/mini.xml`

To stop using the Gateway send a termination request:
`<Static Repository Gateway URL>?terminate=<Static Repository URL>`

Example Gateway Container for a Static Repository Gateway:

```
<?xml version="1.0" encoding="UTF-8"?>
<gateway xmlns="http://www.openarchives.org/OAI/2.0/gateway/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/gateway/
                      http://www.openarchives.org/OAI/2.0/gateway.xsd">
  <source>http://an.oai.org/ma/mini.xml</source>
  <gatewayDescription>http://www.openarchives.org/OAI/2.0/guidelines-static-repository.htm</gatewayDescription>
  <gatewayAdmin>pat@institution.org</gatewayAdmin>
  <gatewayURL>http://bar.edu/oai-gateway/2.0/</gatewayURL>
  <gatewayNotes>http://gateway.institution.org/oai/</gatewayNotes>
</gateway>
```
