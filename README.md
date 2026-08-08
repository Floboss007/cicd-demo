# CI Teaching Kit — Jenkins + Nexus + Tomcat

## Port plan
| Service | Container port | Host port | URL |
|---|---|---|---|
| Jenkins | 8080 | 8080 | http://localhost:8080 |
| Nexus   | 8081 | 8081 | http://localhost:8081 |
| Tomcat  | 8080 | 8082 | http://localhost:8082 |


1. **Push `app/` to a Git repo** (GitHub is fine, keep it public or use a token).
   This is the repo Jenkins will check out.

2. **Start the stack:**
   ```bash
   docker compose up -d --build
   ```
   First run takes a few minutes (Jenkins image build + Nexus init). Grab coffee.

3. **Configure Nexus** (http://localhost:8081):
   - Log in as `admin`, password is in the container:
     `docker exec ci-nexus cat /nexus-data/admin.password`
   - Set a new admin password when prompted.
   - Go to *Server Administration → Repositories* — confirm `maven-releases`
     and `maven-snapshots` already exist (Nexus creates these by default).
   - Go to *Security → Users → Create Local User*:
     - Username: `deployer`, Password: `deployer123`
     - Role: `nx-admin` (fine for a classroom demo — don't do this in production)

   This must match `settings.xml` in this repo, which Jenkins uses to authenticate.

4. **Confirm Tomcat is up:** http://localhost:8082 should show the Tomcat splash page.
   Manager access is already configured via `tomcat-config/`.

5. **Create the Jenkins pipeline job:**
   - http://localhost:8080 → New Item → Pipeline → name it `ci-demo-pipeline`
   - Under *Pipeline*, choose "Pipeline script from SCM" → Git → paste your repo URL
   - Script path: `app/Jenkinsfile`
   - Save, then click **Build Now**

6. **Watch it go green.** If it fails, this is the moment to debug — not live
   in front of students. Common first-run issues:
   - Nexus credentials in `settings.xml` don't match what you set in step 3 → fix and rebuild Jenkins (`docker compose up -d --build jenkins`)
   - Tomcat manager rejects the deploy → check `tomcat-config/tomcat-users.xml` matches `TOMCAT_USER`/`TOMCAT_PASS` in the Jenkinsfile

7. **Verify the deploy:** http://localhost:8082/ci-demo-app/hello should return
   `Hello from the CI/CD demo pipeline!`

8. **Snapshot your working state** so you can reset instantly if a live demo breaks:
   ```bash
   docker commit ci-jenkins ci-jenkins-working-snapshot
   ```
   Or just keep the `jenkins_home` volume around and avoid `docker compose down -v`.

Once the stack is verified

1. **Concepts (diagram, no screens):** Git → Jenkins → Build → Test → Package →
   Nexus (artifact storage) → Tomcat (running app). Emphasize *why* each stage
   exists, not just what it does.

2. **Walk the Jenkinsfile stage by stage** — it's written to be read top to
   bottom like a story. Point out that each `stage {}` block is one step of
   the diagram they just saw.

3. **Run the pipeline live**, watching each stage go green in the Jenkins UI.

4. **Break something on purpose.** Edit `GreeterTest.java`, change the
   expected string, push, rebuild. Watch the Test stage go red and the
   pipeline stop before it ever reaches Nexus or Tomcat. This is usually the
   single most convincing moment in the whole class — it's the *point* of CI.

5. **Fix it, rebuild, watch it go green and deploy.** Load
   `http://localhost:8082/ci-demo-app/hello` in a browser to show the change
   went live automatically.
