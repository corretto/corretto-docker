import json

DEFAULT_ALPINE_VERSION = '3.18'
ALPINE_VERSIONS = ['3.15', '3.16', '3.17', '3.18']

LTS_VERSIONS = [ "8", "11", "17"]
AL2023_GENERIC_VERSIONS = ["20"]

def generate_tags(key, version):
    update = version.split('.')[1] if (key == '8') else version.split('.')[2]
    expanded_version = f"{key}u{update}" if (key == '8') else f"{key}.0.{update}"

    al2_tags = [f"{key}", f"{expanded_version}", f"{expanded_version}-al2", f"{key}-al2-full", f"{key}-al2-jdk", f"{key}-al2-generic", f"{expanded_version}-al2-generic", f"{key}-al2-generic-jdk"]
    al2023_tags = [f"{key}-al2023",  f"{expanded_version}-al2023" ,f"{key}-al2023-jdk"]
    al2023_generic_tags = [f"{key}-al2023-generic", f"{expanded_version}-al2023-generic", f"{key}-al2023-generic-jdk"]
    if key == '8':
        al2_tags.append('latest')


    print("Tags: " + ", ".join(al2_tags) + "")
    print("Architectures: amd64, arm64v8")
    print(f"Directory: {key}/jdk/al2-generic\n")

    if key in LTS_VERSIONS:
        print("Tags: " + ", ".join(al2023_tags) + "")
        print("Architectures: amd64, arm64v8")
        print(f"Directory: {key}/jdk/al2023\n")
        if key == '8':
            print("Tags: " + ", ".join([f"{key}-al2023-jre",  f"{expanded_version}-al2023-jre"]))
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/jdk/al2023\n")
        else:
            print("Tags: " + ", ".join([f"{key}-al2023-headless",  f"{expanded_version}-al2023-headless"]))
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/headless/al2023\n")

            print("Tags: " + ", ".join([f"{key}-al2023-headful",  f"{expanded_version}-al2023-headful"]))
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/headful/al2023\n")

    if key in AL2023_GENERIC_VERSIONS:
        print("Tags: " + ", ".join(al2023_generic_tags) + "")
        print("Architectures: amd64, arm64v8")
        print(f"Directory: {key}/jdk/al2023-generic\n")

    # For LTS versions with modular AmazonLinux packages we want to tag those images
    native_package_modifier="al2-native-"
    if key in ["17"]:
        for image_type in ['headless', 'headful', 'jdk']:
            print(f"Tags: {key}-{native_package_modifier}{image_type}, {expanded_version}-{native_package_modifier}{image_type}")
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/{image_type}/al2\n")

    if key in ["11"]:
        for image_type in ['headless', 'jdk']:
            print(f"Tags: {key}-{native_package_modifier}{image_type}, {expanded_version}-{native_package_modifier}{image_type}")
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/{image_type}/al2\n")

    if key in ["8"]:
        for image_type in ['jre', 'jdk']:
            print(f"Tags: {key}-{native_package_modifier}{image_type}, {expanded_version}-{native_package_modifier}{image_type}")
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/{image_type}/al2\n")

    for alpine_version in ALPINE_VERSIONS:
        alpine_tags = [f"{key}-alpine{alpine_version}", f"{expanded_version}-alpine{alpine_version}", f"{key}-alpine{alpine_version}-full", f"{key}-alpine{alpine_version}-jdk"]
        if alpine_version == DEFAULT_ALPINE_VERSION:
            alpine_tags.extend([f"{key}-alpine", f"{expanded_version}-alpine", f"{key}-alpine-full", f"{key}-alpine-jdk"])
        print("Tags: " + ", ".join(alpine_tags) + "")
        print("Architectures: amd64, arm64v8")
        print(f"Directory: {key}/jdk/alpine/{alpine_version}\n")
        if key == '8':
            alpine_jre_tags = [f"{key}-alpine{alpine_version}-jre", f"{expanded_version}-alpine{alpine_version}-jre"]
            if alpine_version == DEFAULT_ALPINE_VERSION:
                alpine_jre_tags.extend([f"{key}-alpine-jre", f"{expanded_version}-alpine-jre"])
            print("Tags: " + ", ".join(alpine_jre_tags) + "")
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/jre/alpine/{alpine_version}\n")


def main():
    with open('versions.json','r') as version_file:
        versions = json.load(version_file)

    with open('.tags', 'w') as tag_file:
        for key in versions:
            generate_tags(key, versions[key])

if __name__ == "__main__":
    main()
