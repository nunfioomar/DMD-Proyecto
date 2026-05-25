import pandas as pd
from sklearn.cluster import KMeans
import warnings
warnings.filterwarnings('ignore')

print("1. EXTRACCIÓN (Extract)...")
archivo = 'Supersales DMD941.xlsx'

try:
    df = pd.read_excel(archivo)
    print(f"-> Archivo '{archivo}' leído correctamente.")
except Exception as e:
    print(f"Error al leer el archivo: {e}")
    exit()

print("\n2. TRANSFORMACIÓN (Transform) - Limpieza...")
# a. Limpiar espacios ocultos en los nombres de las columnas
df.columns = df.columns.str.strip()

# b. Eliminar registros duplicados
total_inicial = len(df)
df = df.drop_duplicates()

# c. Limpieza de datos nulos usando las columnas ya limpias sin espacios
df = df.dropna(subset=['Sales', 'Profit'])

# d. Normalización de formatos de fecha a yyyy-mm-dd
df['Date'] = pd.to_datetime(df['Date']).dt.strftime('%Y-%m-%d')

print(f"-> Datos limpios. Registros originales: {total_inicial} | Registros válidos: {len(df)}")

print("\n3. MINERÍA DE DATOS - Aplicando K-Means...")

mercado_stats = df.groupby(['Segment', 'Country']).agg({
    'Sales': 'sum',
    'Profit': 'sum'
}).reset_index()

# Aplicamos K-Means para crear 3 segmentos de rentabilidad
kmeans = KMeans(n_clusters=3, random_state=42, n_init=10)
mercado_stats['Segmento_Predictivo'] = kmeans.fit_predict(mercado_stats[['Sales', 'Profit']])

etiquetas = {0: 'Valor Medio', 1: 'Alto Valor', 2: 'Bajo Valor'}
mercado_stats['Segmento_Predictivo'] = mercado_stats['Segmento_Predictivo'].map(etiquetas)

df = df.merge(mercado_stats[['Segment', 'Country', 'Segmento_Predictivo']], on=['Segment', 'Country'], how='left')
print("-> Segmentación completada. Nuevo campo 'Segmento_Predictivo' agregado.")

print("\n4. VISTA PREVIA (Lista para el Datawarehouse)...")
print(df[['Segment', 'Country', 'Sales', 'Profit', 'Segmento_Predictivo']].head())

# Guardamos el resultado en un CSV limpio
archivo_salida = 'Supersales.csv'
df.to_csv(archivo_salida, index=False)
print(f"\n-> ¡Éxito! Archivo limpio guardado como: {archivo_salida}")