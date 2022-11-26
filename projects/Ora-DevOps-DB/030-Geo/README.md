# Geo - Geographical Places

## Featues

* All place types are intentionally represented in `Geo_Places`.
* Any table can reference a place if it's all in one table.
* Geo_Places capture fields that might be relevant to web scraping and machine learning.
* Geo_Places must also consider time as well as place to allow for ancient historical data.

## Requirements

* Oracle Database
* Oracle SQL Developer

## Example Query

```sql
-- --------------------------------------------------------------------------------
-- Demonstrate hierarchical query of data
-- --------------------------------------------------------------------------------
SELECT code, parent_code, place_name, level
FROM geo_places
CONNECT BY prior parent_code = code
START WITH 
    --code = 'BES' 
    place_name = 'Canary Islands';
```

## Entity Relationship Diagram

```plantuml
@startuml
package "Geographical Places" #DDDDDD {

    entity Geo_Place_Types {
        * Code
        # Parent_Code
        + Type_Name
    }

    entity Geo_Places {
        * Code
        + Country_Code_Alpha3
        + Country_Name
        # Region_Code
        + Currency_Code
    }

    entity Geo_Languages {
        * Code
        # Parent_Language_Code
    }

    note right of Geo_Languages 
        Main Country Language 
        with empahsis on 
        internet searching
    end note

    entity Geo_Currencies {
        * Code
        + Currency_Name
        Currency_Start_Dt
        Currency_End_Dt
    }

    Geo_Place_Types ||--|{ Geo_Place_Types
    Geo_Place_Types ||--|{ Geo_Places
    Geo_Places ||--|{ Geo_Places
    Geo_Languages ||--|{ Geo_Places
    Geo_Languages ||--|{ Geo_Places
    Geo_Languages ||--|{ Geo_Places
    Geo_Languages ||--|{ Geo_Languages
    Geo_Currencies ||--|{ Geo_Places
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