# Geo - Geographical Regions

## Requirements

 * Build Oracle database using MV5Servers\Vagrant-XE21c-Apex22
 * Oracle SQL Developer

## Relationship Diagram

```plantuml
@startuml
package "Geographical Regions" #DDDDDD {
    entity Geo_Continents {
        * Code
        + Continent_Name
    }

    entity Geo_Regions {
        * Code
        # Parent_Region_Code
        + Region_Name
        # Continent_Code
    }

    note right of Geo_Regions 
        Regions : Oceania, Europe, 
        Americas, Asia, etc.
    end note

    entity Geo_Languages {
        * Code
        # Parent_Language_Code
    }

    note right of Geo_Languages 
        Main Country Language 
        with empahsis on 
        internet searching
    end note

    entity Geo_Countries {
        * Code
        + Country_Code_Alpha3
        + Country_Name
        # Region_Code
        + Currency_Code
    }

    entity Geo_Country_Currencies {
        * id
        * Code
        # Country_Code
        + Currency_Name
        Currency_Start_Dt
        Currency_End_Dt
    }

    Geo_Continents ||--|{ Geo_Regions
    Geo_Regions ||--|{ Geo_Countries
    Geo_Countries ||--|{ Geo_Country_Currencies
    Geo_Languages ||--|{ Geo_Countries
    Geo_Languages ||--|{ Geo_Languages
}
@enduml
```

<!-- PlantUML Entity Relationship Diagram
Zero or One 	|o--
Exactly One 	||--
Zero or Many 	}o--
One or Many 	}|--

* Primary/Unique column
+ mandatory column
# Foreign column

- private
# protected
~ package private
+ public
-->