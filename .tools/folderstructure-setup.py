import os

# Define the folder structure
folder_structure = {
    ".github": ["workflows"],
    "github-deployment": ["tfvars"],
    "modules": ["azure-container-registry"],
}

# Create folders
for parent, subfolders in folder_structure.items():
    for subfolder in subfolders:
        os.makedirs(os.path.join(parent, subfolder), exist_ok=True)

# Create empty files in the root directory
files = ["README.md", ".gitignore"]

for file in files:
    with open(file, 'w') as f:
        pass  # Just create an empty file

print("Folder structure created successfully!")
