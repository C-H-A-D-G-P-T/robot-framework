# Robot Framework UI & API Testing for Contact List App

This repository showcases **Robot Framework** test automation for both **UI** and **API** layers, using the “Contact List” demo web application hosted at [thinking-tester-contact-list.herokuapp.com](https://thinking-tester-contact-list.herokuapp.com/). It demonstrates building reliable, maintainable tests using best practices in Robot Framework.

---

## 📂 Project Structure

* 📁 **robot-framework-api**
    * 📁 **Resources**
        * 📄 function_keywords.resource
        * 📄 url.yaml
    * 📁 **Result**
        * 📄 contacts.json
    * 📁 **Test**
        * 📄 E2E.robot
* 📁 **robot-framework-ui**
    * 📁 **Resources**
        * 📄 common_keyword.resource
        * 📄 function_keywords.resource
    * 📁 **Result**
        * 📄 contacts.json
    * 📁 **Test**
        * 📄 E2E.robot
* 📄 **README.md**
* 📄 **requirements.txt**

---

## 🛠 Requirements

- Python 3.x
- Robot Framework
- Additional libraries:
  - `robotframework-requests` (API testing)
  - `robotframework-seleniumlibrary` (UI testing)

Install dependencies:

```sh
pip install -r requirements.txt
```

---

## Execution:

#### For UI

```sh
robot -d robot-framework-ui/Result robot-framework-ui/Test
```

#### For API

```sh
robot -d robot-framework-api/Result robot-framework-api/Test
```