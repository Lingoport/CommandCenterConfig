# Long csv locale name
This transform is to get around long locale names.  The Localyzer database for locales as of June 2024 is 10 character wide, so a locale like French will fit in, but a locale like PortugueseBR will not. 

Typically, repositories will use a 5 character locale code, for instance fr-FR, de-DE, pt-BR, as in 
* locales/en-US/messages.json
* locales/pt-BR/messages.json

or
* locales/messages_en_US.properties
* locales/messages_pt_BR.properties

However, when the files in the repositories use long locale codes, this transform will help. For instance, a repository with
* locales/English.csv
* locales/PortugueseBR.csv

will be transformed into
* lcoales/English.csv
* locales/pt-BR.csv

as per the csv_locale_map.properties where PortugueseBR maps to pt-BR, and English is not mapped.

For such a project, on-boarding will require a custom resource file type and:
* this transform
* the correct mapping in csv_locale_map.properties
* the project with English, French, and pt-BR in the repository locales on filenames (not directory names)
* a text type parser
