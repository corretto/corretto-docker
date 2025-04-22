import json

DEFAULT_ALPINE_VERSION = '3.21'
ALPINE_VERSIONS = ['3.19', '3.20', '3.21']

def generate_tags(key, version):
    if type(version) is str:
        generic_update = version.split('.')[1] if (key == '8') else version.split('.')[2]
        generic_expanded_version = f"{key}u{generic_update}" if (key == '8') else f"{key}.0.{generic_update}"
        amazon_expanded_version = generic_expanded_version
        alpine_expanded_version = generic_expanded_version
    else:
        generic_corretto_version = version["GENERIC_LINUX"].split('.')[1] if (key == '8') else version["GENERIC_LINUX"].split('.')[2]
        generic_expanded_version = f"{key}u{generic_corretto_version}" if (key == '8') else f"{key}.0.{generic_corretto_version}"

        amazon_corretto_version = version["AMAZON_LINUX"].split('.')[1] if (key == '8') else version["AMAZON_LINUX"].split('.')[2]
        amazon_expanded_version = f"{key}u{amazon_corretto_version}" if (key == '8') else f"{key}.0.{amazon_corretto_version}"

        alpine_corretto_version = version["ALPINE"].split('.')[1] if (key == '8') else version["ALPINE"].split('.')[2]
        alpine_expanded_version = f"{key}u{alpine_corretto_version}" if (key == '8') else f"{key}.0.{alpine_corretto_version}"


    al2023_tags = [f"{key}-al2023",  f"{amazon_expanded_version}-al2023" ,f"{key}-al2023-jdk"]
    al2023_headless_tags = [f"{key}-al2023-headless",  f"{amazon_expanded_version}-al2023-headless"]
    al2023_headful_tags = [f"{key}-al2023-headful",  f"{amazon_expanded_version}-al2023-headful"]
    # These only apply for Corretto8 which does not have the same modulare packages as 11+
    al2023_8_tags = [f"{key}-al2023-jre",  f"{amazon_expanded_version}-al2023-jre"]

    if int(key) <= 21:
        al2_tags = [f"{key}", f"{generic_expanded_version}", f"{generic_expanded_version}-al2", f"{key}-al2-full", f"{key}-al2-jdk", f"{key}-al2-generic", f"{generic_expanded_version}-al2-generic", f"{key}-al2-generic-jdk"]
        if key == '8':
            al2_tags.append('latest')
        print("Tags: " + ", ".join(al2_tags) + "")
        print("Architectures: amd64, arm64v8")
        print(f"Directory: {key}/jdk/al2-generic\n")

    # Starting with Corretto 22 AL2 based images are not longer vended and AL2023 will be the
    # default base OS until the next AL version is GA.
    if int(key) >= 22:
        al2023_tags.append(f"{key}")
        al2023_tags.append(f"{key}-jdk")
        al2023_headless_tags.append(f"{key}-headless")
        al2023_headful_tags.append(f"{key}-headful")

    print("Tags: " + ", ".join(al2023_tags) + "")
    print("Architectures: amd64, arm64v8")
    print(f"Directory: {key}/jdk/al2023\n")
    if key == '8':
        print("Tags: " + ", ".join(al2023_8_tags))
        print("Architectures: amd64, arm64v8")
        print(f"Directory: {key}/jdk/al2023\n")
    else:
        print("Tags: " + ", ".join(al2023_headless_tags))
        print("Architectures: amd64, arm64v8")
        print(f"Directory: {key}/headless/al2023\n")

        print("Tags: " + ", ".join(al2023_headful_tags))
        print("Architectures: amd64, arm64v8")
        print(f"Directory: {key}/headful/al2023\n")

    # For LTS versions with modular AmazonLinux 2 packages we want to tag those images
    native_package_modifier="al2-native-"
    if key in ["17"]:
        for image_type in ['headless', 'headful', 'jdk']:
            print(f"Tags: {key}-{native_package_modifier}{image_type}, {amazon_expanded_version}-{native_package_modifier}{image_type}")
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/{image_type}/al2\n")

    if key in ["11"]:
        for image_type in ['headless', 'jdk']:
            print(f"Tags: {key}-{native_package_modifier}{image_type}, {amazon_expanded_version}-{native_package_modifier}{image_type}")
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/{image_type}/al2\n")

    if key in ["8"]:
        for image_type in ['jre', 'jdk']:
            print(f"Tags: {key}-{native_package_modifier}{image_type}, {amazon_expanded_version}-{native_package_modifier}{image_type}")
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/{image_type}/al2\n")

    for alpine_version in ALPINE_VERSIONS:
        alpine_tags = [f"{key}-alpine{alpine_version}", f"{alpine_expanded_version}-alpine{alpine_version}", f"{key}-alpine{alpine_version}-full", f"{key}-alpine{alpine_version}-jdk"]
        if alpine_version == DEFAULT_ALPINE_VERSION:
            alpine_tags.extend([f"{key}-alpine", f"{alpine_expanded_version}-alpine", f"{key}-alpine-full", f"{key}-alpine-jdk"])
        print("Tags: " + ", ".join(alpine_tags) + "")
        print("Architectures: amd64, arm64v8")
        print(f"Directory: {key}/jdk/alpine/{alpine_version}\n")
        if key == '8':
            alpine_jre_tags = [f"{key}-alpine{alpine_version}-jre", f"{alpine_expanded_version}-alpine{alpine_version}-jre"]
            if alpine_version == DEFAULT_ALPINE_VERSION:
                alpine_jre_tags.extend([f"{key}-alpine-jre", f"{alpine_expanded_version}-alpine-jre"])
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
