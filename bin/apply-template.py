import jinja2
import json
import shutil
import os

def process_template_files(major_version, version, platform):
    templateLoader = jinja2.FileSystemLoader(searchpath="./templates/")
    templateEnv = jinja2.Environment(autoescape=jinja2.select_autoescape(['html', 'xml']), loader=templateLoader)

    template = templateEnv.get_template(f"{platform}.Dockerfile.template")
    input_parameter = {}
    input_parameter['CORRETTO_VERSION'] = version
    input_parameter['MAJOR_VERSION'] = major_version
    input_parameter['JDK_VERSION'] = '1.8.0'
    if platform == 'alpine':
        # Update .github/workflows/verify-images.yml as well when alpine versions changes
        os_versions = ['3.15', '3.16', '3.17', '3.18']  
    try:
        shutil.rmtree(f"{major_version}/jdk/{platform}")
        shutil.rmtree(f"{major_version}/jre/{platform}")
    except:
        pass
    if platform == 'alpine':
        for os_version in os_versions:
            input_parameter['OS_VERSION'] = os_version
            os.makedirs(f"{major_version}/jdk/{platform}/{os_version}/", exist_ok=True)
            with open(f"{major_version}/jdk/{platform}/{os_version}/Dockerfile", 'w') as output:
                output.write(template.render(**input_parameter))
        
            if major_version == '8':
                os.makedirs(f"{major_version}/jre/{platform}/{os_version}/", exist_ok=True)
                with open(f"{major_version}/jre/{platform}/{os_version}/Dockerfile", 'w') as output:
                    output.write(template.render(**input_parameter, **{'jre':True}))

    elif 'headless' in platform or 'headful' in platform:
        head_variant = 'headless' if 'headless' in platform else 'headful'
        if major_version==11 or major_version==17:
            os.makedirs(f"{major_version}/{head_variant}/{platform}/", exist_ok=True)
            with open(f"{major_version}/{head_variant}/{platform}/Dockerfile", 'w') as output:
                output.write(template.render(**input_parameter))

    elif platform == 'al2023-generic':
        if major_version==20:
            os.makedirs(f"{major_version}/jdk/{platform}/", exist_ok=True)
            with open(f"{major_version}/{head_variant}/{platform}/Dockerfile", 'w') as output:
                output.write(template.render(**input_parameter))

    else:            
        os.makedirs(f"{major_version}/jdk/{platform}/", exist_ok=True)
        with open(f"{major_version}/jdk/{platform}/Dockerfile", 'w') as output:
            if major_version == '8':
                output.write(template.render(**input_parameter, **{'version_8':True}))
            elif major_version == '11':
                output.write(template.render(**input_parameter, **{'version_11':True}))
            else:
                output.write(template.render(**input_parameter))

        if major_version == '8' and platform != 'al2-generic':
            os.makedirs(f"{major_version}/jre/{platform}/", exist_ok=True)
            with open(f"{major_version}/jre/{platform}/Dockerfile", 'w') as output:
                output.write(template.render(**input_parameter, **{'jre':True, 'version_8':True}))


def main():
    with open('versions.json','r') as version_file:
        versions = json.load(version_file)
    
    for key in versions:
        process_template_files(key, versions[key], 'alpine')
        process_template_files(key, versions[key], 'al2')
        process_template_files(key, versions[key], 'al2-generic')
        process_template_files(key, versions[key], 'al2-headful')
        process_template_files(key, versions[key], 'al2-headless')
        process_template_files(key, versions[key], 'al2023')
        process_template_files(key, versions[key], 'al2023-generic')
        process_template_files(key, versions[key], 'al2023-headful')
        process_template_files(key, versions[key], 'al2023-headless')

if __name__ == "__main__":
    main()
