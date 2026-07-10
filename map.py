import os
import json

def generate_rig_based_manifest(root_dir, output_filename="contents.json"):
    """
    Scans asset folders and structures a JSON manifest anchored around filenames in 'rigs'.
    Animations and variations are read cleanly from their own separate directories.
    """
    root_dir = os.path.abspath(root_dir)
    output_file_abs = os.path.abspath(os.path.join(root_dir, output_filename))
    
    # Define separate, distinct directories relative to root
    rigs_dir = os.path.join(root_dir, "rigs")
    anims_dir = os.path.join(root_dir, "animations")
    ref_dir = os.path.join(root_dir, "reference")
    previews_root_dir = os.path.join(root_dir, "previews")
    models_dir = os.path.join(root_dir, "models")
    variations_dir = os.path.join(root_dir, "variations")
    
    # Verify the rigs anchor directory exists before starting
    if not os.path.exists(rigs_dir):
        print(f"Error: The 'rigs' directory was not found inside: {root_dir}")
        return

    manifest = {}

    # Helper function to find a single file by base name with any extension
    def find_file_path(target_folder, asset_name, folder_label):
        if not os.path.exists(target_folder):
            return ""
        for file in os.listdir(target_folder):
            name_only, _ = os.path.splitext(file)
            if name_only == asset_name:
                return f"/{folder_label}/{file}"
        return ""

    # Helper function to turn system paths into clean forward-slash strings
    def clean_path(rel_path):
        return f"/{rel_path.replace(os.sep, '/')}"

    # 1. Extract base asset names from the rigs directory
    for file in os.listdir(rigs_dir):
        name_only, ext = os.path.splitext(file)
        
        # Skip hidden system files
        if file.startswith("."):
            continue
            
        # Initialize your exact dictionary schema format
        manifest[name_only] = {
            "rig": f"/rigs/{file}",
            "animations": [],
            "reference": find_file_path(ref_dir, name_only, "reference"),
            "previews": [],
            "model": find_file_path(models_dir, name_only, "models"),
            "variations": []
        }
        
        # 2. Scan the separate animations folder (matches "bird-" or "bird.")
        if os.path.exists(anims_dir):
            prefix_dash = f"{name_only}-"
            prefix_dot = f"{name_only}."
            for a_file in os.listdir(anims_dir):
                if a_file.startswith(".") or not os.path.isfile(os.path.join(anims_dir, a_file)):
                    continue
                if a_file.startswith(prefix_dash) or a_file.startswith(prefix_dot):
                    rel_a_path = os.path.relpath(os.path.join(anims_dir, a_file), root_dir)
                    manifest[name_only]["animations"].append(clean_path(rel_a_path))
        
        # 3. Scan the specific previews subfolder for this asset (e.g., previews/bird/)
        specific_preview_dir = os.path.join(previews_root_dir, name_only)
        if os.path.exists(specific_preview_dir):
            for p_file in os.listdir(specific_preview_dir):
                if os.path.isfile(os.path.join(specific_preview_dir, p_file)) and not p_file.startswith("."):
                    rel_p_path = os.path.relpath(os.path.join(specific_preview_dir, p_file), root_dir)
                    manifest[name_only]["previews"].append(clean_path(rel_p_path))
                    
        # 4. Scan the completely separate variations folder (strictly matches "bird-")
        if os.path.exists(variations_dir):
            prefix_dash = f"{name_only}-"
            for v_file in os.listdir(variations_dir):
                if v_file.startswith(".") or not os.path.isfile(os.path.join(variations_dir, v_file)):
                    continue
                if v_file.startswith(prefix_dash):
                    rel_v_path = os.path.relpath(os.path.join(variations_dir, v_file), root_dir)
                    manifest[name_only]["variations"].append(clean_path(rel_v_path))

    # 5. Export the clean layout data directly to your JSON file
    with open(output_file_abs, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=4)
        
    print(f"Successfully generated rig-based asset layout file at: {output_file_abs}")

# --- SETUP RUN ---
target_folder = r"./m2m"
generate_rig_based_manifest(target_folder)

# // go through the rigs folder and get all the names e.g. "bird.glb" remove .glb and use these as the starting json names

# {
#   "bird": {
#     "rig":  location_from_rigs_folder,
#     "animations": [], //list of paths of the animations from variations folder with the name "bird-" or "bird." at the begining
#     "reference": location_from_reference_folder,
#     "previews": [], //list of paths of the previews from previews/bird folder
#     "model": location_from_models_folder,
#     "variations": [] //list of paths of the previews from variations folder with the name "bird-" at the begining
#   }
# }