#!/bin/bash
# Help choose the right Docker template based on project needs

echo "Docker Template Selector"
echo "========================"
echo ""
echo "Answer a few questions to find the right template:"
echo ""

# Question 1: Language
echo "1. What's your primary language/framework?"
echo "   a) Node.js/JavaScript"
echo "   b) Python"
echo "   c) React"
echo "   d) Vue.js"
echo "   e) Next.js"
read -p "Choice (a-e): " lang_choice

# Question 2: Complexity
echo ""
echo "2. What's your current project stage?"
echo "   a) Just starting - want minimal setup"
echo "   b) Need a database"
echo "   c) Need database + caching"
echo "   d) Need optimized production build"
read -p "Choice (a-d): " complexity_choice

# Recommendations
echo ""
echo "Recommended templates:"
echo "====================="

# Dockerfile recommendation
case $lang_choice in
    a)
        if [ "$complexity_choice" = "a" ]; then
            echo "Dockerfile: dockerfile-minimal"
        elif [ "$complexity_choice" = "d" ]; then
            echo "Dockerfile: dockerfile-multistage"
        else
            echo "Dockerfile: dockerfile-minimal (upgrade later if needed)"
        fi
        ;;
    b)
        if [ "$complexity_choice" = "a" ]; then
            echo "Dockerfile: dockerfile-python-minimal"
        else
            echo "Dockerfile: dockerfile-python-minimal (upgrade later if needed)"
        fi
        ;;
    c)
        echo "Dockerfile: dockerfile-react"
        ;;
    d)
        echo "Dockerfile: dockerfile-vue"
        ;;
    e)
        echo "Dockerfile: dockerfile-nextjs"
        ;;
esac

# Docker Compose recommendation
case $complexity_choice in
    a)
        echo "Docker Compose: docker-compose-minimal.yml (or none if single container)"
        ;;
    b)
        echo "Docker Compose: docker-compose-with-db.yml"
        ;;
    c)
        echo "Docker Compose: docker-compose-with-cache.yml"
        ;;
    d)
        echo "Docker Compose: Start with your current setup, optimize gradually"
        ;;
esac

echo ""
echo "Build command:"
echo "============="
echo "./scripts/build-no-cache.sh your-app-name"
echo ""
echo "Remember: Always start minimal and add complexity only when needed!"