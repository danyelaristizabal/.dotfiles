#!/usr/bin/env python3

import sys 
import requests
from requests.auth import HTTPBasicAuth
import os 
import json
import subprocess
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('claude_tasks.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

def get_issues():
    api_key = os.getenv('ATLASSIAN')
    if not api_key:
        print("Error: ATLASSIAN environment variable is not set")
        print("Please set it with: export ATLASSIAN='your_api_key'")
        sys.exit(1)

    # JIRA configuration
    email = "danyel.aristizabal@modak.live"
    url = "https://modaklive.atlassian.net/rest/api/3/search/jql"
    auth = HTTPBasicAuth(email, api_key)

    headers = {
        "Accept": "application/json"
    }

    query = {
        'jql': 'project = MBB and assignee = currentUser() and status in ("In Progress")',
        'fields': 'summary,description',
    }

    response = requests.get(
        url,
        headers=headers,
        params=query,
        auth=auth
    )

    data = response.json()

    # Create a map of IssueKey: description
    issue_map = {}


    print(f"data {data}\n")
    if "issues" in data:
        for issue in data["issues"]:
            desc_obj = issue.get("fields", {}).get("description", {})
            description_text = extract_description(desc_obj).replace("\n", " ").replace("\r", " ").strip()
            issue_key = issue.get('key')
            issue_map[issue_key] = description_text
            
            print(f"{issue_key}: {description_text}")

        print(f"Retrieved {len(issue_map)} issues")
    else:
        print(json.dumps(data, sort_keys=True, indent=4, separators=(",", ": ")))
    
    return issue_map

def extract_description(desc_obj):
    if isinstance(desc_obj, dict):
        if "text" in desc_obj:
            return desc_obj["text"]
        elif "content" in desc_obj:
            return " ".join(extract_description(item) for item in desc_obj["content"])
        else:
            return ""
    elif isinstance(desc_obj, list):
        return " ".join(extract_description(item) for item in desc_obj)
    return ""

def process_issue(issue_key, description_text):
    success = create_branch(issue_key)
    if not success:
        print(f"✗ Create branch failed for {issue_key}\n")
        return
    
    max_retries = 3
    retry_count = 0
    task_description = description_text  
    while retry_count < max_retries:
        print(f"Trying with Claude Code (attempt {retry_count + 1})...")
        claude_output, claude_errors = call_claude_code(task_description)

        if not (claude_output is not None or claude_errors == "Timeout"): # timeout is also success as it may be waiting user input, to do check if the 
            print(f"✗ Claude Code call failed for {issue_key}: {claude_errors}")
            logger.error(f"Claude Code call failed for {issue_key}: {claude_errors}")
            print(f"Continuing with next issue...\n")
            return

        print(f"Running validations (attempt {retry_count + 1}/{max_retries})...")
        success, lint_errors, test_errors = validate()
        
        if success:
            print("✓ All validations passed")
            break
        
        retry_count += 1
        
        if retry_count >= max_retries:
            print(f"✗ Max retries reached, validations still failing aborting")
            break
        
        git_diff = get_git_diff()
        
        task_description = f"""
        Original task: {description_text} 
        Git diff:
        {git_diff} 
        failed lint results: 
        {lint_errors}
        failed test results: 
        {test_errors}"""

    
    print(f"Committing and pushing branch for {issue_key}...")
    push_success = git_push()
    if not push_success:
        print(f"✗ Git commit and push failed for {issue_key}\n")
        logger.error(f"Git commit and push failed for {issue_key}")
        return
    
    print(f"✓ Git commit and push succeeded for {issue_key}\n")
    logger.info(f"Git commit and push succeeded for {issue_key}")

def create_branch(issue_key):
    try:
        # Checkout main branch
        subprocess.run(["git", "checkout", "main"], check=True, capture_output=True, text=True)
        print(f"Checked out main branch")
        
        # Pull latest changes
        result = subprocess.run(["git", "pull"], check=True, capture_output=True, text=True)
        print(f"Pulled latest changes: {result.stdout.strip()}")
        
        # Create and checkout new branch
        branch_name = issue_key.lower()
        subprocess.run(["git", "checkout", "-b", branch_name], check=True, capture_output=True, text=True)
        print(f"Created and checked out branch: {branch_name}")
        
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"Git operation failed for {issue_key}: {e}")
        return False
    except Exception as e:
        print(f"Error during git operations for {issue_key}: {e}")
        return False

def call_claude_code(description):
    try:
        
        result = subprocess.run(
            ["claude", "--dangerously-skip-permissions", "-p", description], 
            capture_output=True, 
            text=True, 
            timeout=500,
            input=""  # Provide empty input to prevent hanging
        )
        
        print(f"Claude Code output:\n{result.stdout}")
        if result.stderr:
            print(f"Claude Code errors:\n{result.stderr}")
        
        return result.stdout, result.stderr
        
    except subprocess.TimeoutExpired as e:
        error_msg = f"Claude Code call timed out after 5 minutes"
        logger.error(error_msg)
        print(error_msg)
        return None, "Timeout"
    except subprocess.CalledProcessError as e:
        error_msg = f"Claude Code call failed: {e}"
        logger.error(error_msg)
        print(error_msg)
        return None, str(e)
    except Exception as e:
        error_msg = f"Error calling Claude Code: {e}"
        logger.error(error_msg)
        print(error_msg)
        return None, str(e)

def validate(): 
        go_path = os.path.join(os.getcwd(), "go")
        if not os.path.exists(go_path):
            print("No go directory found")
            return False, "", ""
            
        # Get all subdirectories in go/
        subdomains = [d for d in os.listdir(go_path) if os.path.isdir(os.path.join(go_path, d))]
        
        failed_tests = []
        failed_lints = []
        
        for subdomain in subdomains:
            subdomain_path = os.path.join(go_path, subdomain)
            print(f"Running validation for subdomain: {subdomain}")

            os.chdir(subdomain_path)

            lint_output = f"=== Linting for {subdomain} ===\n"
            lint_success, lint_output = check_lint()
            if lint_success:
                print(f"✓ Linting passed for {subdomain}")
            else: 
                print(f"✗ Linting failed for {subdomain}")
                failed_lints.append((subdomain, lint_output))

            test_output = f"=== Tests for {subdomain} ===\n"
            test_success, test_output = check_unit_tests()
            if test_success:
                print(f"✓ Tests passed for {subdomain}")
            else:
                print(f"✗ Tests failed for {subdomain}")
                failed_tests.append((subdomain, test_output))
        
        os.chdir("..") 
        os.chdir("..") 

        success = len(failed_tests) == 0 and len(failed_lints) == 0
        return success, failed_tests, failed_lints 
                
def check_unit_tests(): 
    try: 
        result = subprocess.run(["go", "test", "./..."], capture_output=True, text=True, timeout=300)
        
        if result.returncode == 0:
            return True, result.stdout 
        else:
            return False, f"output:\n{result.stdout}\n{result.stderr}"
            
    except subprocess.TimeoutExpired:
        return False, "Tests timed out"
    except Exception as e:
        return False, f"Error running tests: {e}" 

def check_lint(): 
    try:
        result = subprocess.run(["golangci-lint", "run", "--fix"], capture_output=True, text=True, timeout=300)
        if result.returncode == 0:
            return True, result.stdout 
        else:
            return False, f"output:\n{result.stdout}\n{result.stderr}"

    except FileNotFoundError:
        print("golangci-lint not found, skipping linting")
        return True, ""
    except Exception as e:
        print(f"Error during linting: {e}")
        return False, ""

def get_git_diff():
    try:
        result = subprocess.run(["git", "diff"], capture_output=True, text=True)
        return result.stdout
    except Exception as e:
        print(f"Error getting git diff: {e}")
        return ""

def git_push():
    try:
        # Add all changes
        subprocess.run(["git", "add", "."], check=True, capture_output=True, text=True)
        print("Added all changes to staging area")
        
        # Commit changes
        commit_result = subprocess.run(["git", "commit", "-m", "Automated changes via Claude Code"], check=True, capture_output=True, text=True)
        print(f"Committed changes: {commit_result.stdout.strip()}")
        
        # Push current branch to remote
        push_result = subprocess.run(["git", "push", "-u", "origin", "HEAD"], check=True, capture_output=True, text=True)
        print(f"Git push successful: {push_result.stdout.strip()}")
        
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"Git operation failed: {e}")
        return False
    except Exception as e:
        print(f"Error during git operations: {e}")
        return False

# Main execution
if __name__ == "__main__":
    os.chdir("domain-fintech")#to do: identify the project by the description of the issue 

    # First, retrieve all issues
    issue_map = get_issues()
    
    # Then, process each issue
    for issue_key, description_text in issue_map.items():
        process_issue(issue_key, description_text)

