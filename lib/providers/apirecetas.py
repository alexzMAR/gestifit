import requests
from googletrans import Translator

API_KEY = '21c26904af854ee5b21784f365c92545'
BASE_URL = 'https://api.spoonacular.com/recipes/complexSearch'
RECIPE_URL = 'https://api.spoonacular.com/recipes/{id}/information'

translator = Translator()

def search_recipes(query):
    try:
        response = requests.get(BASE_URL, params={
            'apiKey': API_KEY,
            'query': query,
            'number': 10,
            'instructionsRequired': True,
            'addRecipeInformation': True
        })
        response.raise_for_status()
        return response.json().get('results', [])
    except requests.exceptions.RequestException as e:
        print(f"Error en la búsqueda de recetas: {e}")
        return []

def get_recipe_details(recipe_id):
    try:
        response = requests.get(RECIPE_URL.format(id=recipe_id), params={
            'apiKey': API_KEY,
            'includeNutrition': False
        })
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error al obtener detalles de la receta: {e}")
        return {}

def get_suggested_recipes():
    try:
        response = requests.get(BASE_URL, params={
            'apiKey': API_KEY,
            'sort': 'popularity',
            'number': 5,
            'instructionsRequired': True,
            'addRecipeInformation': True
        })
        response.raise_for_status()
        return response.json().get('results', [])
    except requests.exceptions.RequestException as e:
        print(f"Error al obtener recetas sugeridas: {e}")
        return []

def translate_text(text, target_language='es'):
    if text is None:
        return ''  # Retornar un string vacío si el texto es None
    try:
        return translator.translate(text, dest=target_language).text
    except Exception as e:
        print(f"Error al traducir: {e}")
        return text  # Retornar el texto original en caso de error

def main():
    recipes = []
    suggested_recipes = []
    while True:
        print("\n1. Buscar recetas")
        print("2. Ver detalles de la receta")
        print("3. Ver platos sugeridos")
        print("4. Ver detalles de platos sugeridos")
        print("5. Salir")
        choice = input("\nSeleccione una opción: ")

        if choice == '1':
            query = input("\nIngrese el nombre del plato: ")
            recipes = search_recipes(query)
            print("\nResultados de la búsqueda:")
            for idx, recipe in enumerate(recipes, start=1):
                title = recipe.get('title')
                title_translated = translate_text(title) if title else 'Sin título'
                print(f"{idx}. {title_translated} (ID: {recipe['id']})")

        elif choice == '2':
            if recipes:
                try:
                    selected_recipe_idx = int(input("\nIngrese el número de la receta que desea ver los detalles: ")) - 1
                    if 0 <= selected_recipe_idx < len(recipes):
                        selected_recipe_id = recipes[selected_recipe_idx]['id']
                        recipe = get_recipe_details(selected_recipe_id)
                        title = recipe.get('title')
                        title_translated = translate_text(title) if title else 'Sin título'
                        print(f"\nTítulo: {title_translated}")
                        print("Ingredientes:")
                        for ingredient in recipe.get('extendedIngredients', []):
                            ingredient_name = ingredient.get('original')
                            ingredient_translated = translate_text(ingredient_name) if ingredient_name else ''
                            print(f" - {ingredient_translated}")
                        instructions = recipe.get('instructions')
                        instructions_translated = translate_text(instructions) if instructions else 'No hay instrucciones disponibles'
                        print(f"Instrucciones: {instructions_translated}")
                        print(f"Fuente: {recipe.get('sourceUrl', 'No disponible')}")
                    else:
                        print("Número de receta no válido.")
                except ValueError:
                    print("Por favor, ingrese un número válido.")
            else:
                print("\nPrimero debe buscar recetas utilizando la opción 1.")

        elif choice == '3':
            suggested_recipes = get_suggested_recipes()
            print("\nPlatos sugeridos:")
            for idx, recipe in enumerate(suggested_recipes, start=1):
                title = recipe.get('title')
                title_translated = translate_text(title) if title else 'Sin título'
                print(f"{idx}. {title_translated} (ID: {recipe['id']})")

        elif choice == '4':
            if suggested_recipes:
                try:
                    selected_suggested_recipe_idx = int(input("\nIngrese el número de la receta sugerida que desea ver los detalles: ")) - 1
                    if 0 <= selected_suggested_recipe_idx < len(suggested_recipes):
                        selected_recipe_id = suggested_recipes[selected_suggested_recipe_idx]['id']
                        recipe = get_recipe_details(selected_recipe_id)
                        title = recipe.get('title')
                        title_translated = translate_text(title) if title else 'Sin título'
                        print(f"\nTítulo: {title_translated}")
                        print("Ingredientes:")
                        for ingredient in recipe.get('extendedIngredients', []):
                            ingredient_name = ingredient.get('original')
                            ingredient_translated = translate_text(ingredient_name) if ingredient_name else ''
                            print(f" - {ingredient_translated}")
                        instructions = recipe.get('instructions')
                        instructions_translated = translate_text(instructions) if instructions else 'No hay instrucciones disponibles'
                        print(f"Instrucciones: {instructions_translated}")
                        print(f"Fuente: {recipe.get('sourceUrl', 'No disponible')}")
                    else:
                        print("Número de receta no válido.")
                except ValueError:
                    print("Por favor, ingrese un número válido.")
            else:
                print("\nPrimero debe obtener platos sugeridos utilizando la opción 3.")

        elif choice == '5':
            break

if __name__ == '__main__':
    main()
