# ReferenceTemperatureOACI
This is a method for calculating the aerodrome reference temperature as defined by ICAO.

# Calcul de la Température de Référence d’Aérodrome

Ce fichier décrit les étapes pour calculer la **température de référence d’aérodrome** conformément à la définition de l'OACI (Convention relative à l'aviation civile internationale, Annexe 14, Volume I, 2.4.1).

## Définition
La température de référence d’aérodrome est définie comme **la moyenne mensuelle des températures maximales quotidiennes** pour **le mois le plus chaud de l’année** (le mois ayant la température moyenne mensuelle la plus élevée). Cette température est moyennée sur une période d’analyse climatologique standard (généralement 30 ans).

---

## Méthodologie

### 1. Collecte des données
- Rassembler les **températures maximales quotidiennes (Tmax)** pour chaque jour de l’année.
- Couvrir une période d’au moins **10 à 30 ans** pour garantir la fiabilité des résultats.
- Formats acceptés : CSV, Excel, ou toute autre base de données structurée.

### 2. Identification du mois le plus chaud
- Calculer la **température moyenne mensuelle** pour chaque mois de l’année et chaque année.
  \[
  T_{\text{moy, mois}} = \frac{1}{N} \sum_{i=1}^{N} T_{\text{max, quotidienne, jour } i}
  \]
  où \( N \) est le nombre de jours dans le mois.
- Identifier le mois ayant la température moyenne mensuelle la plus élevée chaque année.

### 3. Calcul de la température moyenne pour le mois le plus chaud
- Pour chaque année, calculer la moyenne des \( T_{\text{max}} \) pour tous les jours du mois le plus chaud.

### 4. Calcul final de la température de référence
- Moyennez les températures des mois les plus chauds pour toutes les années analysées :
  \[
  T_{\text{référence}} = \frac{1}{n} \sum_{i=1}^{n} T_{\text{moy, mois chaud, année } i}
  \]
  où \( n \) est le nombre d’années de données.

---

## Exemple de Script Python
Ci-dessous un script Python simple pour effectuer ce calcul :

```python
import pandas as pd

# Charger les données
# Assurez-vous que votre fichier CSV contient les colonnes 'Date' et 'Tmax'
data = pd.read_csv("data_temperature.csv")
data['Date'] = pd.to_datetime(data['Date'])
data['Year'] = data['Date'].dt.year
data['Month'] = data['Date'].dt.month

# Calcul des moyennes mensuelles
data_grouped = data.groupby(['Year', 'Month'])['Tmax'].mean().reset_index()

# Identification du mois le plus chaud par année
hottest_months = data_grouped.loc[data_grouped.groupby('Year')['Tmax'].idxmax()]

# Calcul de la température de référence
temperature_reference = hottest_months['Tmax'].mean()
print(f"Température de référence : {temperature_reference:.2f}°C")
```

````R
library(tidyverse)
library(readxl)

data_init <- read_excel(path = "Workbook1_donnees.xls")
unique_months <- data_init %>% pull(var = Month) %>% unique()

data_init <- data_init %>% 
  mutate(
    Month = factor(Month, levels = unique_months)
  )


data_init %>% head()

tcm_data <- data_init %>% select(Station_Name, Year, Month, TCM) %>% 
  pivot_wider(names_from = Month, values_from = TCM) %>% 
  select(!Annuel)

hot_months <- tcm_data %>% 
  select(Janvier:Decembre) %>% 
  apply(MARGIN = 1, FUN = which.max)


tcm_data$hot_months <- hot_months
tcm_data$hot_months_names <- unique_months[hot_months]

tcm_data <- tcm_data %>% select(Station_Name, Year, hot_months, hot_months_names)


tmax_data <- data_init %>% 
  select(Station_Name, Year, Month, TMAX)

ref_temp_data <- tmax_data %>% 
  right_join(y = tcm_data, by = c('Station_Name' = 'Station_Name', 'Year' = 'Year', 'Month' = 'hot_months_names'))


ref_temp_data %>% 
  group_by(Station_Name) %>% 
  summarise(
    ref_temp = mean(TMAX),
    count = n()
  )
````
---

## Applications
- **Aménagement des infrastructures aéroportuaires** : évaluation des conditions thermiques extrêmes.
- **Aviation** : optimisation des performances des aéronefs selon les conditions locales.
- **Climatologie** : étude des tendances de réchauffement climatique sur des périodes longues.

---

## Ressources supplémentaires
- [OACI - Convention relative à l’aviation civile internationale](https://www.icao.int)

